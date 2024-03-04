// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var url4 =
      "https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4";
 

  var downloadManager = DownloadManager();
  var savedDir = "";

  @override
  void initState() {
    super.initState();
    getApplicationSupportDirectory().then((value) => savedDir = value.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Download Manager")),
      body: SingleChildScrollView(
        child: Column(
          children: [
         
          
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Batch Downloads"),
                  ),
       
                  ListItem(
                      onDownloadPlayPausedPressed: (url) async {
                        setState(() {
                          var task = downloadManager.getDownload(url);

                          if (task != null && !task.status.value.isCompleted) {
                            switch (task.status.value) {
                              case DownloadStatus.downloading:
                                downloadManager.pauseDownload(url);
                                break;
                              case DownloadStatus.paused:
                                downloadManager.resumeDownload(url);
                                break;
                                                              default:

                            }
                          } else {
                            downloadManager.addDownload(url,
                                "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                          }
                        });
                      },
                      onDelete: (url) {
                        var fileName =
                            "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                        var file = File(fileName);
                        file.delete();

                        downloadManager.removeDownload(url);
                        setState(() {});
                      },
                      url: url4,
                      downloadTask: downloadManager.getDownload(url4)),
               
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            downloadManager.addBatchDownloads(
                              [url4], savedDir);
                            setState(() {});
                          },
                          child: const Text("Download All")),
                      TextButton(
                          onPressed: () {
                            downloadManager
                                .pauseBatchDownloads([ url4,]);
                          },
                          child: const Text("Pause All")),
                      TextButton(
                          onPressed: () {
                            downloadManager
                                .cancelBatchDownloads([ url4,]);
                          },
                          child: const Text("Cancel All")),
                    ],
                  ),
                  ValueListenableBuilder(
                      valueListenable: downloadManager
                          .getBatchDownloadProgress([url4]),
                      builder: (context, value, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: LinearProgressIndicator(
                            value: value,
                          ),
                        );
                      }),
                  FutureBuilder<List<DownloadTask?>?>(
                      future: downloadManager
                          .whenBatchDownloadsComplete([url4]),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DownloadTask?>?> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Text(
                                'I will wait till the batch downloads have been completed');
                          default:
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return snapshot.data != null
                                  ? Column(children: [
                                      const Text("Result"),
                                      for (var e in snapshot.data!)
                                        e != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "${downloadManager.getFileNameFromUrl(e.request.url)}: ${e.status.value}"),
                                              )
                                            : const Text("Not found"),
                                    ])
                                  : const Text("No Downloads have been found");
                            }
                        }
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  DownloadTask? downloadTask;
  String url = "";

  ListItem(
      {super.key,
      required this.url,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
      this.downloadTask});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.amber,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      url,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (downloadTask != null)
                      ValueListenableBuilder(
                          valueListenable: downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text("$value",
                                  style: const TextStyle(fontSize: 16)),
                            );
                          }),
                  ],
                )),
                downloadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: downloadTask!.status,
                        builder: (context, value, child) {
                          
                           switch(downloadTask!.status.value) {
                            case DownloadStatus.downloading:
                              return IconButton(
                                  onPressed: () {
                                    onDownloadPlayPausedPressed(url);
                                  },
                                  icon: const Icon(Icons.pause));
                            case DownloadStatus.paused:
                              return IconButton(
                                  onPressed: () {
                                    onDownloadPlayPausedPressed(url);
                                  },
                                  icon: const Icon(Icons.play_arrow));
                            case DownloadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    onDelete(url);
                                  },
                                  icon: const Icon(Icons.delete));
                            case DownloadStatus.failed:
                            case DownloadStatus.canceled:
                              return IconButton(
                                  onPressed: () {
                                    onDownloadPlayPausedPressed(url);
                                  },
                              
                                  icon: const Icon(Icons.download));
                                   default: {}
                                   
                          }
                         return Text("$value", style: const TextStyle(fontSize: 16));
                        })
                    : IconButton(
                        onPressed: () {
                          onDownloadPlayPausedPressed(url);
                        },
                        icon: const Icon(Icons.download))
              ],
            ), // if (widget.item.isDownloadingOrPaused)
            if (downloadTask != null && !downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color:
                            downloadTask!.status.value == DownloadStatus.paused
                                ? Colors.grey
                                : Colors.amber,
                      ),
                    );
                  }),
            if (downloadTask != null)
              FutureBuilder<DownloadStatus>(
                  future: downloadTask!.whenDownloadComplete(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DownloadStatus> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text(
                            'I will wait till this download has been completed');
                      default:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text('Result: ${snapshot.data}');
                        }
                    }
                  })
          ],
        ),
      ),
    );
  }
}