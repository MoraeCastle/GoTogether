import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chatview/chatview.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/MessageItem.dart';
import 'package:go_together/models/Room.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/models/data.dart';
import 'package:go_together/models/theme.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/notification.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 채팅방 씬
class ChatRoomView extends StatefulWidget {
  const ChatRoomView({Key? key, required this.arguments}) : super(key: key);
  final Map<String, String> arguments;

  @override
  State<ChatRoomView> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatRoomView> with WidgetsBindingObserver{
  Logger logger = Logger();
  
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  // listen
  late StreamSubscription<DatabaseEvent> childChange;

  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  String travelCode = "";
  String userCode = "";
  String chatTitle = "";
  int chatUserCount = 0;
  List<String> chatUserStrList = [];
  // List<ChatUser> userList = [];
  List<Message> chatList = [];
  Room targetRoom = Room();
  String roomProfileURL = "";
  late ChatController _chatController;

  // 기준 유저
  late ChatUser currentUser;

  /// 오류로 인한 나가기.
  Future<bool> finishDialog() async {
    return (await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.pop(context);
        },
        child: AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: const Text('오류'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 60),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '서버에 문제가 있습니다.\n나중에 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.info_outline_rounded),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text('나가기')),
          ],
        ),
      ),
    ));
  }

  /// 기기 데이터 불러오기
  Future<void> getDeviceData() async {
    SharedPreferences prefs = await _prefs;
    travelCode = prefs.getString(SystemData.travelCode) ?? "";
    userCode = prefs.getString(SystemData.userCode) ?? "";
    chatTitle = prefs.getString(SystemData.chatTitle) ?? "";
    chatUserCount = prefs.getInt(SystemData.chatUserCount) ?? 0;
    chatUserStrList = prefs.getStringList(SystemData.chatUserList) ?? [];
  }

  /// 채팅에 참여하는 유저 초기화
  Future<void> getChatUser() async {
    await getDeviceData();

    List<ChatUser> resultList = [];

    // 인원 상세데이터 불러오기
    if (travelCode.isNotEmpty) {
      ref = FirebaseDatabase.instance.ref();
      var snapshot = await ref.child('travel/$travelCode').get();
      if (snapshot.exists) {
        var result = snapshot.value;
        if (result != null) {
          var travel = Travel.fromJson(result);

          for (String userStr in chatUserStrList) {
            for (User user in travel.getUserList().values) {
              if (user.getUserCode() == userStr) {
                resultList.add(ChatUser(
                  id: user.getUserCode(),
                  name: user.getName(),
                  // profilePhoto: Data.profileImage,
                  profilePhoto: user.getProfileURL().isNotEmpty ? user.getProfileURL() : Data.defaultImage,
                ));
                break;
              }
            }
          }
        } else {
          finishDialog();
        }
      } else {
        // 여행 데이터 불러오기 오류...
        finishDialog();
      }
    }

    _chatController.chatUsers = resultList;

    if (resultList.isNotEmpty) {
      getChatList();
      // 알림메세지 모두 읽음처리
      FlutterLocalNotification.cancelAllNotifications();
    } else {
      finishDialog();
    }
  }

  /// 채팅 목록을 가져오고 최신화합니다.
  void getChatList() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('chat/$travelCode');
    childChange = ref.onValue.listen((DatabaseEvent event) async {
      final result = event.snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        // 이 채팅방인지?
        for (Room room in chat.getRoomList()) {
          if (room.getTitle() == chatTitle) {
            targetRoom = room;
            chatList = room.getChatList();
            
            _chatController.initialMessageList = [];
            _chatController.loadMoreData(chatList);

            break;
          }
        }

        // 채팅 프로필 이미지 지정.
        if (targetRoom.getTitle().isNotEmpty) {
          if (targetRoom.getState() == 1) {
            roomProfileURL = await NetworkUtil.getNoticeProfileURL();
          }

          // 채팅인원 오류 검증
          rearrangeList(chatList);

          // 읽음처리.
          if (targetRoom.getMessageList().length != targetRoom.getUserMap()[userCode]! || !targetRoom.getCurrentPeople().contains(userCode)) {
            targetRoom.getUserMap()[userCode] = targetRoom.getMessageList().length;
            targetRoom.addCurrent(userCode);

            try{
              Room item = chat.getRoomList().firstWhere((element) => element.getTitle() == targetRoom.getTitle());
              item = targetRoom;
              await ref.set(chat.toJson());
            } catch(e) {
              // 갱신 실패...
            }
          }
        }

        setState(() {});
      } else {
        BotToast.showText(text: "데이터가 없습니다...");
      }
    });

    BotToast.closeAllLoading();
  }

  /// 리스트 재정렬.
  /// 채팅내용중 퇴장한 인원이 있는경우 퇴장인원으로 추가합니다.
  rearrangeList(List<Message> list) {
    for (Message message in list) {
      // 채팅 유저리스트에 이 아이디가 없다면?
      if (_chatController.chatUsers.where((user) => user.id == message.sendBy).isEmpty) {
        // 인원 추가
        _chatController.chatUsers.add(ChatUser(
          id: message.sendBy,
          name: '(퇴장한 인원)',
          profilePhoto: Data.defaultImage,
        ));
      }
    }
  }

  @override
  void initState() {
    BotToast.showLoading();

    currentUser = ChatUser(
      id: widget.arguments['userCode'] ?? "",
      name: widget.arguments['userName'] ?? "",
      profilePhoto: Data.profileImage,
    );

    _chatController = ChatController(
      // initialMessageList: Data.messageList,
      initialMessageList: chatList,
      scrollController: ScrollController(),
      chatUsers: [],
    );

    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    getChatUser();
  }

  /// 뒤로 나가기 할 떄...
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    childChange.cancel();
    super.dispose();
  }

  /// 앱 홈으로 이동해서 돌아왔을 때...
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    logger.e('>>> lifecyle callback...: ${describeEnum(state)}');
    if (state == AppLifecycleState.resumed) {
      // 앱으로 복귀했을 때.
      childChange.resume();
      NetworkUtil.changeLeaveAllChatRoom(travelCode, chatTitle, userCode, false);
      // 알림메세지 모두 읽음처리
      FlutterLocalNotification.cancelAllNotifications();
    } else if (state == AppLifecycleState.paused) {
      // 홈 화면으로 나갔을 때.
      // 방에서 나감처리.
      childChange.pause();
      NetworkUtil.changeLeaveAllChatRoom(travelCode, chatTitle, userCode, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          childChange.cancel();

          // 채팅방 나감으로 변경..
          await NetworkUtil.changeLeaveAllChatRoom(travelCode, chatTitle, userCode, true);
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            ChatView(
              currentUser: currentUser,
              chatController: _chatController,
              onSendTap: _onSendTap,
              featureActiveConfig: const FeatureActiveConfig(
                lastSeenAgoBuilderVisibility: true,
                receiptsBuilderVisibility: true,
              ),
              chatViewState: ChatViewState.hasMessages,
              chatViewStateConfig: ChatViewStateConfiguration(
                loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                  loadingIndicatorColor: theme.outgoingChatBubbleColor,
                ),
                onReloadButtonTap: () {},
              ),
              typeIndicatorConfig: TypeIndicatorConfiguration(
                flashingCircleBrightColor: theme.flashingCircleBrightColor,
                flashingCircleDarkColor: theme.flashingCircleDarkColor,
              ),
              appBar: ChatViewAppBar(
                elevation: theme.elevation,
                backGroundColor: theme.appBarColor,
                profilePicture: roomProfileURL,
                backArrowColor: theme.backArrowColor,
                chatTitle: targetRoom.getTitle(),
                chatTitleTextStyle: TextStyle(
                  color: theme.appBarTitleTextStyle,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.25,
                ),
                userStatus: targetRoom.getMessageList().isEmpty
                    ? "새 채팅방" : SystemUtil.getTodayStr(DateTime.parse(targetRoom.getMessageList().last.createdAt)),
                userStatusTextStyle: const TextStyle(color: Colors.grey),
                onBackPress: () async {
                  // 채팅방 나감으로 변경..
                  childChange.cancel();

                  await NetworkUtil.changeLeaveAllChatRoom(travelCode, chatTitle, userCode, true);
                  Navigator.pop(context);
                },
              ),
              chatBackgroundConfig: ChatBackgroundConfiguration(
                messageTimeIconColor: theme.messageTimeIconColor,
                messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
                defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                  textStyle: TextStyle(
                    color: theme.chatHeaderColor,
                    fontSize: 17,
                  ),
                ),
                backgroundColor: theme.backgroundColor,
              ),
              sendMessageConfig: SendMessageConfiguration(
                // 미디어 전송은 미구현.
                enableCameraImagePicker: false,
                enableGalleryImagePicker: false,
                allowRecordingVoice: false,
                imagePickerIconsConfig: ImagePickerIconsConfiguration(
                  cameraIconColor: theme.cameraIconColor,
                  galleryIconColor: theme.galleryIconColor,
                ),
                replyMessageColor: theme.replyMessageColor,
                defaultSendButtonColor: theme.sendButtonColor,
                replyDialogColor: theme.replyDialogColor,
                replyTitleColor: theme.replyTitleColor,
                textFieldBackgroundColor: theme.textFieldBackgroundColor,
                closeIconColor: theme.closeIconColor,
                textFieldConfig: TextFieldConfiguration(
                  onMessageTyping: (status) {
                    /// Do with status
                    debugPrint(status.toString());
                  },
                  compositionThresholdTime: const Duration(seconds: 1),
                  textStyle: TextStyle(color: theme.textFieldTextColor),
                ),
                micIconColor: theme.replyMicIconColor,
                voiceRecordingConfiguration: VoiceRecordingConfiguration(
                  backgroundColor: theme.waveformBackgroundColor,
                  recorderIconColor: theme.recordIconColor,
                  waveStyle: WaveStyle(
                    showMiddleLine: false,
                    waveColor: theme.waveColor ?? Colors.white,
                    extendWaveform: true,
                  ),
                ),
              ),
              chatBubbleConfig: ChatBubbleConfiguration(
                outgoingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(
                    backgroundColor: theme.linkPreviewOutgoingChatColor,
                    bodyStyle: theme.outgoingChatLinkBodyStyle,
                    titleStyle: theme.outgoingChatLinkTitleStyle,
                  ),
                  receiptsWidgetConfig:
                  const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
                  color: theme.outgoingChatBubbleColor,
                ),
                inComingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(
                    linkStyle: TextStyle(
                      color: theme.inComingChatBubbleTextColor,
                      decoration: TextDecoration.underline,
                    ),
                    backgroundColor: theme.linkPreviewIncomingChatColor,
                    bodyStyle: theme.incomingChatLinkBodyStyle,
                    titleStyle: theme.incomingChatLinkTitleStyle,
                  ),
                  textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  onMessageRead: (message) {
                    /// send your message reciepts to the other client
                    debugPrint('Message Read');
                    BotToast.showText(text: '메세지를 읽음..');
                  },
                  senderNameTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                  color: theme.inComingChatBubbleColor,
                ),
              ),
              replyPopupConfig: ReplyPopupConfiguration(
                backgroundColor: theme.replyPopupColor,
                buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
                topBorderColor: theme.replyPopupTopBorderColor,
              ),
              reactionPopupConfig: ReactionPopupConfiguration(
                shadow: BoxShadow(
                  color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
                  blurRadius: 20,
                ),
                backgroundColor: theme.reactionPopupColor,
              ),
              messageConfig: MessageConfiguration(
                messageReactionConfig: MessageReactionConfiguration(
                  backgroundColor: theme.messageReactionBackGroundColor,
                  borderColor: theme.messageReactionBackGroundColor,
                  reactedUserCountTextStyle:
                  TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionCountTextStyle:
                  TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                    backgroundColor: theme.backgroundColor,
                    reactedUserTextStyle: TextStyle(
                      color: theme.inComingChatBubbleTextColor,
                    ),
                    reactionWidgetDecoration: BoxDecoration(
                      color: theme.inComingChatBubbleColor,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                          offset: const Offset(0, 20),
                          blurRadius: 40,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                imageMessageConfig: ImageMessageConfiguration(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shareIconConfig: ShareIconConfiguration(
                    defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                    defaultIconColor: theme.shareIconColor,
                  ),
                ),
              ),
              profileCircleConfig: const ProfileCircleConfiguration(
                profileImageUrl: Data.profileImage,
              ),
              repliedMessageConfig: RepliedMessageConfiguration(
                backgroundColor: theme.repliedMessageColor,
                verticalBarColor: theme.verticalBarColor,
                repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                  enableHighlightRepliedMsg: true,
                  highlightColor: Colors.pinkAccent.shade100,
                  highlightScale: 1.1,
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.25,
                ),
                replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
              ),
              swipeToReplyConfig: SwipeToReplyConfiguration(
                replyIconColor: theme.swipeToReplyIconColor,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,  
              child: Visibility(
                visible: chatUserStrList.isEmpty,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                            '데이터를 불러오고 있습니다...'
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ),
          ],
        )
      )
    );
  }

  /// 채팅 액션
  Future<void> _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      ) async {

    /*Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });*/

    var snapshot = await ref.child('chat/$travelCode').get();
    if (snapshot.exists) {
      var result = snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        for (Room room in chat.getRoomList()) {
          if (room.getTitle() == chatTitle) {
            MessageItem item = MessageItem();

            item.setId(room.getMessageList().length + 1);
            item.setCreatedAt(DateTime.now().toString());
            item.setMessage(message);
            item.setSendBy(userCode);
            item.setReplyMessageId(replyMessage.messageId == '' ? 0 : int.parse(replyMessage.messageId));

            room.getMessageList().add(item);

            // 채팅 메세지를 보냄과 함꼐 읽음처리 갱신.
            room.getUserMap()[userCode] = room.getMessageList().length;
            room.addCurrent(userCode);

            await ref.child('chat/$travelCode').set(chat.toJson());

            /*Future.delayed(const Duration(seconds: 1), () {
              _chatController.initialMessageList.last.setStatus = MessageStatus.read;
            });*/
            break;
          }
        }
      }
      BotToast.closeAllLoading();
    } else {
      BotToast.closeAllLoading();
    }
  }
}