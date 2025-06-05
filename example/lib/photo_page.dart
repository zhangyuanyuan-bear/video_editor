import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotoPage extends StatefulWidget {
  final Function(AssetEntity)? onTap; // 点击图片回调，用于打开大图

  const PhotoPage({super.key, this.onTap});
  @override
  State<StatefulWidget> createState() {
    return _PhotoPage();
  }
}

class _PhotoPage extends State<PhotoPage> {
  List<AssetPathEntity> _paths = [];

  List<AssetEntity> _assets = [];

  Map<String, int> durationMap = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPhotoData();
    });
  }

  void getPhotoData() async {
    final paths = await PhotoManager.getAssetPathList(hasAll: false, type: RequestType.video);

    setState(() {
      _paths = paths;
    });
    if (_paths.isNotEmpty) {
      final assets = await _paths[0].getAssetListRange(start: 0, end: 20);
      for (AssetEntity asset in assets) {
        int duration = asset.duration;
        durationMap[asset.id] = duration;
        debugPrint('duration -- $duration');
      }
      setState(() {
        _assets = assets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo')),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _paths.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  width: 120,
                  child: ListTile(
                    title: Text(_paths[index].name),
                    onTap: () async {
                      final assets = await _paths[index].getAssetListRange(start: 0, end: 20);
                      setState(() {
                        _assets = assets;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                return CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AssetEntityImage(
                          _assets[index],
                          isOriginal: false,
                          thumbnailSize: ThumbnailSize.square(600),
                          fit: BoxFit.cover,
                          // 大相册，看脸
                          alignment: Alignment.topCenter,
                          loadingBuilder: (_, child, progress) {
                            if (progress != null) {
                              return Container(color: Colors.red);
                            }
                            return child;
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Text(
                          durationString(_assets[index].id),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    widget.onTap?.call(_assets[index]);
                  },
                );
              },
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 10, bottom: 30),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                childAspectRatio: 9 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String durationString(String id) {
    int? duration = durationMap[id];
    if (duration == null) {
      return '00:00';
    }
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
