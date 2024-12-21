// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:airbnb/components/my_icon_button.dart';
import 'package:flutter/material.dart';
import '../model/message_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.title});
  final String title;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late OpenAI openAI;
  TextEditingController controller = TextEditingController();
  String results = "results to be shown here";
  List<ChatMessage> messages =
<ChatMessage>[
];
ChatUser openAIuser =
ChatUser(
id: '2',
firstName: 'ChatGPT',
lastName: 'AI',
);
  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
        token:
           // "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",
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
        enableLog: true);
  }

  void chatComplete() async {
    final request = ChatCompleteText(
        messages: [
          Map.of({"role": "user", "content": controller.text})
        ],
        maxToken: 200,
        model:
            GptTurbo0301ChatModel()); //Gpt41106PreviewChatModel());//GptTurbo0301ChatModel());
    final response = await openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      print("data -> ${element.message?.content}");
      results = element.message!.content;
      ChatMessage msg = ChatMessage(
          user: openAIuser,
          createdAt: DateTime.now(),
          text: element.message!.content);
      messages.insert(0, msg);
      setState(() {
        messages;
      });
      setState(() {
        results;
      });
    }
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
            Expanded(child: Text(results)),
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
