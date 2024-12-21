import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.title});
  final String title;
  @override
  State<MessagesScreen> createState() => _MyMessagesScreen();
}

class _MyMessagesScreen extends State<MessagesScreen> {
  TextEditingController controller = TextEditingController();
  String results = "results to be shown here";
  late OpenAI openAI;

  List<ChatMessage> messages = <ChatMessage>[];
  ChatUser userMe = ChatUser(
    id: '1',
    firstName: 'Taraggy',
    lastName: 'Ghanim',
  );
  ChatUser openAIuser = ChatUser(
    id: '2',
    firstName: 'ChatGPT',
    lastName: 'AI',
  );

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
        token: "",
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 25)),
        enableLog: true);
  }

  void chatComplete() async {
    if (controller.text.trim().isEmpty) {
      print("Input is empty. Please type a message.");
      return;
    }

    try {
      final request = ChatCompleteText(
        messages: [
          {"role": "user", "content": controller.text}
        ],
        maxToken: 100, // Reduce token limit for lower usage
        model: GptTurbo0631Model(), // Specify GPT-3.5-Turbo
      );

      controller.text = "";

      final response = await openAI.onChatCompletion(request: request);

      if (response == null || response.choices.isEmpty) {
        print("No response from the API.");
        return;
      }

      for (var element in response.choices) {
        final content = element.message?.content;
        if (content != null) {
          print("data -> $content");

          results = content;
          ChatMessage msg = ChatMessage(
            user: openAIuser,
            createdAt: DateTime.now(),
            text: content,
          );

          setState(() {
            messages.insert(0, msg);
          });
        }
      }
    } catch (e) {
      if (e.toString().contains('insufficient_quota')) {
        print("You have exceeded your free quota. Please wait for the reset.");
      } else {
        print("Error during chat completion: $e");
      }
    }
  }

  Future<void> _generateImage() async {
    var prompt = controller.text;
    final request = GenerateImage(
        model: DallE2(),
        prompt,
        1,
        size: ImageSize.size256,
        responseFormat: Format.url);
    GenImgResponse? response = await openAI.generateImage(request);
    print("img url :${response?.data?.last?.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: DashChat(
              messages: messages,
              currentUser: userMe,
              onSend: (m) {},
              readOnly: true,
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                    child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: 'Type here...', border: InputBorder.none),
                    ),
                  ),
                )),
                ElevatedButton(
                  onPressed: () {
                    ChatMessage msg = ChatMessage(
                        user: userMe,
                        createdAt: DateTime.now(),
                        text: controller.text);
                    messages.add(msg); // note the add function effect
                    setState(() {
                      messages;
                    });
                    chatComplete();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Colors.blue),
                )
              ]),
            ) // Row
          ],
        ),
      ),
    );
  }
}
