import 'package:flutter/material.dart';
import 'package:pubnub/core.dart';
import 'package:pubnub/pubnub.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:notification_permissions/notification_permissions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameTEC = TextEditingController(text: ''),
      emailTEC = TextEditingController(text: '');
  PubNub pubNub = PubNub(
    defaultKeyset: Keyset(
      publishKey: 'pub-c-a7c54197-6491-4eb2-a166-1c4986cabe1b',
      subscribeKey: 'sub-c-07cae1f6-b93b-11eb-8313-02017f28bfc9',
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () async {
                PubNub pubNub = PubNub(
                  defaultKeyset: Keyset(
                    publishKey: 'pub-c-a7c54197-6491-4eb2-a166-1c4986cabe1b',
                    subscribeKey: 'sub-c-07cae1f6-b93b-11eb-8313-02017f28bfc9',
                  ),
                );
                final user = await pubNub.objects.getUUIDMetadata(
                  uuid: 'test@gmail.com',
                  includeCustomFields: true,
                );
                final custom = user.metadata.custom as Map<String, dynamic>;
                final String password = custom['password'];
                String text = '';
                if ('test' == password) {
                  text = 'Welcome';
                } else {
                  text = 'You Can\'t Enter';
                }
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(text)));
              },
              child: Text('Sign'),
            ),
            TextButton(
              onPressed: () async {
                final createUser = await pubNub.objects.setUUIDMetadata(
                  UuidMetadataInput(
                    name: 'test',
                    email: 'test@gmail.com',
                    custom: {'password': 'test'},
                  ),
                  uuid: 'test@gmail.com',
                  includeCustomFields: true,
                );
                print(createUser.metadata.email);
              },
              child: Text('signup'),
            ),
            TextButton(
              onPressed: () async {
                final getAllUuidMetadataResult =
                    await pubNub.objects.getAllUUIDMetadata();
                final metadataList = getAllUuidMetadataResult.metadataList;
                for (final userData in metadataList) print(userData.email);
              },
              child: Text('get all users'),
            ),
            TextButton(
              onPressed: () async {
                final uuid = 'test@gmail.com ';

                print('removed: $uuid');
              },
              child: Text('delete user'),
            ),
            TextButton(
              onPressed: () async {
                final v = await pubNub.objects.setChannelMetadata('id',
                    ChannelMetadataInput(name: 'name', description: 'des'));
              },
              child: Text('create channel'),
            ),
            TextButton(
              onPressed: () async {
                final channelId = 'id';
                final removeChannelMetaDataResult =
                    await pubNub.objects.removeChannelMetadata('id');
                print('remove $channelId');
              },
              child: Text('delete channel'),
            ),
            TextButton(
              onPressed: () async {
                final channelName = "channel-test";
                final channelMetaData =
                    await pubNub.objects.getChannelMetadata(channelName);
                final channel = pubNub.channel(channelMetaData.metadata.name);
                final publishResult = await channel.publish(
                  {
                    'message': 'hi hmed naser',
                    'uuid': 'test@gmail.com',
                  },
                  storeMessage: true,
                  ttl: 0,
                );
                print(publishResult.timetoken);
              },
              child: Text('send message to channel'),
            ),
            TextButton(
              onPressed: () async {
                final channelName = "channel-test";
                final channelMetaData =
                    await pubNub.objects.getChannelMetadata(channelName);
                final channel = pubNub.channel(channelMetaData.metadata.name);

                final chat = await channel.history().more();
                final messages = chat.messages.cast<Map<String, dynamic>>();
                print(messages);
              },
              child: Text('recive messages from channel'),
            ),
            TextButton(
              onPressed: () async {
                final permissionStatus = await NotificationPermissions
                        .getNotificationPermissionStatus()
                    .then<String>((status) {
                  switch (status) {
                    case PermissionStatus.denied:
                      return 'denied';
                    case PermissionStatus.granted:
                      return 'granted';
                    case PermissionStatus.unknown:
                      return 'unknown';
                    case PermissionStatus.provisional:
                      return 'provisional';
                    default:
                      return null;
                  }
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$permissionStatus')));
              },
              child: Text('get permission access notification'),
            ),
            TextButton(
              onPressed: () async {
                final getAllChannelMetadataResult =
                    await pubNub.objects.getAllChannelMetadata();
                final channels = getAllChannelMetadataResult.metadataList;
                for (final channel in channels)
                  print(channel.name.toString() + '  ' + channel.id);
              },
              child: Text('get all channel'),
            ),
            TextButton(
              onPressed: () async {
                final deviceId = await PlatformDeviceId.getDeviceId;

                final channelName = "channel-test";
                final addPushChannelsResult = await pubNub.addPushChannels(
                  deviceId,
                  PushGateway.gcm,
                  {channelName},
                );

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('added $deviceId to channel $channelName')));
              },
              child: Text('add device to push notification'),
            ),
            TextButton(
              onPressed: () async {
                final deviceId = await PlatformDeviceId.getDeviceId;

                final channelName = "channel-test";
              },
              child: Text('a push notification'),
            ),
          ],
        ),
      ),
    );
  }

// https://www.pubnub.com/docs/rest-api
  @override
  void dispose() {
    nameTEC.dispose();
    emailTEC.dispose();
    super.dispose();
  }
}
