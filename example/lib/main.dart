import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_editor_example/photo_page.dart';
import 'package:video_editor_example/video_editor.dart';

void main() => runApp(
      MaterialApp(
        title: 'Flutter Video Editor Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          brightness: Brightness.dark,
          tabBarTheme: const TabBarTheme(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          dividerColor: Colors.white,
        ),
        home: const VideoEditorExample(),
      ),
    );

class VideoEditorExample extends StatefulWidget {
  const VideoEditorExample({super.key});

  @override
  State<VideoEditorExample> createState() => _VideoEditorExampleState();
}

class _VideoEditorExampleState extends State<VideoEditorExample> {
  Future<bool> checkPermission() async {
    final status = await Permission.photos.status;
    debugPrint('status --- $status');
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;

      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.provisional:
        PermissionStatus requestStatus = await Permission.photos.request();
        debugPrint('requestStatus --- $requestStatus');
        switch (requestStatus) {
          case PermissionStatus.granted:
          case PermissionStatus.limited:
            return true;
          case PermissionStatus.denied:
          case PermissionStatus.restricted:
          case PermissionStatus.permanentlyDenied:
          case PermissionStatus.provisional:
            return false;
        }
    }
  }

  void _pickVideo() async {
    if (!(await checkPermission())) {
      debugPrint('没有权限');
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => PhotoPage(
            onTap: (AssetEntity entity) async {
              final file = await entity.file;
              if (file == null) return;
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => VideoEditor(
                      file: file,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Click on the button to select video"),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("Pick Video From Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
