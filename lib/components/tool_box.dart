import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/edit_tool_provider.dart';

class ToolBox extends StatefulWidget {
  const ToolBox({super.key});

  @override
  State<ToolBox> createState() => _ToolBoxState();
}

class _ToolBoxState extends State<ToolBox> {
  Tools tool = Tools.eraser;
  @override
  Widget build(BuildContext context) {
    print('rebuild');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // The Tool
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height * .207,
            child: Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  tool.toolSettings,
                ],
              ),
            ),
          ),
        ),
        BottomAppBar(
          child: Container(
              color: Colors.grey[400],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (tool != Tools.hand) {
                        setState(() {
                          tool = Tools.hand;
                          context.read<EditTool>().setTool(tool);
                        });
                      }
                    },
                    child: const Icon(FontAwesomeIcons.solidHand),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tool != Tools.eraser) {
                        setState(() {
                          tool = Tools.eraser;
                          context.read<EditTool>().setTool(tool);
                        });
                      }
                    },
                    child: const Icon(FontAwesomeIcons.eraser),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tool != Tools.snip) {
                        setState(() {
                          tool = Tools.snip;
                          context.read<EditTool>().setTool(tool);
                        });
                      }
                    },
                    child: const Icon(Icons.content_cut_rounded),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tool != Tools.crop) {
                        setState(() {
                          tool = Tools.crop;
                          context.read<EditTool>().setTool(tool);
                        });
                      }
                    },
                    child: const Icon(Icons.crop),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tool != Tools.auto) {
                        setState(() {
                          tool = Tools.auto;
                          context.read<EditTool>().setTool(tool);
                        });
                      }
                    },
                    child: const Icon(Icons.auto_awesome),
                  )
                ],
              )

              // return
              // Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   //The Tool Icons
              //   children: [
              //   context.read<Blur>().setBlur(true);
              //   ],
              // List.generate(
              //   colors.length,
              //   (index) => _buildColorChooser(colors[index]),
              // ),
              // );

              ),
        ),
      ],
    );
  }
}
