// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Message Launcher',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home: const MessageListScreen(),
//     );
//   }
// }

// class MessageListScreen extends StatelessWidget {
//   const MessageListScreen({super.key});

//   // Dummy message list
//   final List<Map<String, String>> messageList = const [
//     {"phone": "01700000001", "message": "Hello! কেমন আছেন?"},
//     {"phone": "01700000002", "message": "আপনার অর্ডার রেডি!"},
//     {"phone": "01700000003", "message": "Thanks for contacting us!"},
//   ];

//   void _launchMessage(String phoneNumber, String message) async {
//     final String url = 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';

//     if (await canLaunchUrlString(url)) {
//       await launchUrlString(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Message List'),
//       ),
//       body: ListView.builder(
//         itemCount: messageList.length,
//         itemBuilder: (context, index) {
//           final item = messageList[index];
//           return ListTile(
//             leading: const Icon(Icons.message),
//             title: Text(item['message']!),
//             subtitle: Text('To: ${item['phone']}'),
//             onTap: () {
//               if (item["phone"] != null) {
//                 _launchMessage(item["phone"]!, item["message"]!);
//               } else {
//                 print("No phone number available for messaging");
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:another_telephony/telephony.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Direct SMS Sender',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: const MessageListScreen(),
//     );
//   }
// }

// class MessageListScreen extends StatefulWidget {
//   const MessageListScreen({super.key});

//   @override
//   State<MessageListScreen> createState() => _MessageListScreenState();
// }

// class _MessageListScreenState extends State<MessageListScreen> {
//   final Telephony telephony = Telephony.instance;
//   final List<Map<String, String>> messageList = const [
//     {"phone": "01581183499", "message": "Hello! কেমন আছেন?"},
//     {"phone": "01791487265", "message": "আপনার অর্ডার রেডি!"},
//     {
//       "phone": "01700525823",
//       "message":
//           "I Check How to send sms directly mobile app, developer: Bahar khan"
//     },
//   ];

//   final Set<int> selectedIndexes = {};
//   bool isLoading = false;
//   int selectedSimSlot = 0; // Default SIM 1
//   bool hasSmsPermission = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAndRequestPermissions();
//   }

//   Future<void> _checkAndRequestPermissions() async {
//     // Check if we have SMS permission
//     var status = await Permission.sms.status;
//     if (!status.isGranted) {
//       status = await Permission.sms.request();
//     }

//     // Also request phone state permission which might be needed
//     var phoneStatus = await Permission.phone.status;
//     if (!phoneStatus.isGranted) {
//       phoneStatus = await Permission.phone.request();
//     }

//     setState(() {
//       hasSmsPermission = status.isGranted;
//     });

//     if (!hasSmsPermission) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("SMS permission is required")),
//         );
//       }
//     }
//   }

//   void _sendSelectedMessages() async {
//     if (!hasSmsPermission) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please grant SMS permissions first")),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       for (int index in selectedIndexes) {
//         final item = messageList[index];
//         final phone = item['phone']!;
//         final message = item['message']!;

//         // Validate phone number
//         if (phone.isEmpty || !RegExp(r'^[0-9+]+$').hasMatch(phone)) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Invalid phone number: $phone")),
//           );
//           continue;
//         }

//         // Send SMS
//         await telephony.sendSms(
//           to: phone,
//           message: message,
//           subscriptionId: selectedSimSlot,
//         );

//         //debugPrint("SMS send result: $result");

//         await Future.delayed(const Duration(milliseconds: 800));
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Messages sent successfully!")),
//         );
//       }
//     } catch (e, stackTrace) {
//       debugPrint("Error sending SMS: $e");
//       debugPrint("Stack trace: $stackTrace");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to send messages: ${e.toString()}")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           selectedIndexes.clear();
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Message List'),
//         actions: [
//           if (hasSmsPermission)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: DropdownButton<int>(
//                 value: selectedSimSlot,
//                 dropdownColor: Colors.white,
//                 underline: const SizedBox(),
//                 icon: const Icon(Icons.sim_card, color: Colors.white),
//                 items: const [
//                   DropdownMenuItem(value: 0, child: Text("SIM 1")),
//                   DropdownMenuItem(value: 1, child: Text("SIM 2")),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedSimSlot = value;
//                     });
//                   }
//                 },
//               ),
//             ),
//           if (!hasSmsPermission)
//             IconButton(
//               icon: const Icon(Icons.error, color: Colors.red),
//               onPressed: _checkAndRequestPermissions,
//               tooltip: "Permissions needed",
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (!hasSmsPermission)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 color: Colors.red[100],
//                 child: ListTile(
//                   leading: const Icon(Icons.warning, color: Colors.red),
//                   title: const Text("Permissions Required"),
//                   subtitle: const Text("Tap to grant SMS permissions"),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.settings),
//                     onPressed: () => openAppSettings(),
//                   ),
//                   onTap: _checkAndRequestPermissions,
//                 ),
//               ),
//             ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: messageList.length,
//               itemBuilder: (context, index) {
//                 final item = messageList[index];
//                 final isSelected = selectedIndexes.contains(index);

//                 return ListTile(
//                   leading: Checkbox(
//                     value: isSelected,
//                     onChanged: hasSmsPermission
//                         ? (bool? selected) {
//                             setState(() {
//                               if (selected == true) {
//                                 selectedIndexes.add(index);
//                               } else {
//                                 selectedIndexes.remove(index);
//                               }
//                             });
//                           }
//                         : null,
//                   ),
//                   title: Text(item['message']!),
//                   subtitle: Text('To: ${item['phone']}'),
//                   onTap: hasSmsPermission
//                       ? () {
//                           setState(() {
//                             if (isSelected) {
//                               selectedIndexes.remove(index);
//                             } else {
//                               selectedIndexes.add(index);
//                             }
//                           });
//                         }
//                       : null,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: selectedIndexes.isNotEmpty && hasSmsPermission
//           ? FloatingActionButton.extended(
//               onPressed: isLoading ? null : _sendSelectedMessages,
//               icon: isLoading
//                   ? const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     )
//                   : const Icon(Icons.send),
//               label: Text(isLoading
//                   ? "Sending..."
//                   : "Send (${selectedIndexes.length})"),
//             )
//           : null,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart' as telephony;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direct SMS Sender',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MessageListScreen(),
    );
  }
}

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final telephony.Telephony _telephony = telephony.Telephony.instance;
  final List<Map<String, String>> messageList = const [
    {"phone": "01581183499", "message": "Hello! কেমন আছেন?"},
    {"phone": "01791487265", "message": "আপনার অর্ডার রেডি!"},
    {
      "phone": "01700525823",
      "message":
          "I Check How to send sms directly mobile app, developer: Bahar khan"
    },
  ];

  final Set<int> _selectedIndexes = {};
  bool _isLoading = false;
  int _selectedSimSlot = 1; // Default SIM 1 (usually 1 is the first SIM)
  bool _hasSmsPermission = false;
  bool _useDirectSmsApi = false; // Toggle between methods

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _initTelephony();
  }

  Future<void> _initTelephony() async {
    try {
      final bool? hasPermission =
          await _telephony.requestPhoneAndSmsPermissions;
      setState(() {
        _hasSmsPermission = hasPermission ?? false;
      });
    } catch (e) {
      debugPrint("Error initializing telephony: $e");
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    try {
      // Request SMS permission
      var smsStatus = await Permission.sms.status;
      if (!smsStatus.isGranted) {
        smsStatus = await Permission.sms.request();
      }

      // Request phone permission (needed for SIM selection)
      var phoneStatus = await Permission.phone.status;
      if (!phoneStatus.isGranted) {
        phoneStatus = await Permission.phone.request();
      }

      setState(() {
        _hasSmsPermission = smsStatus.isGranted && phoneStatus.isGranted;
      });

      if (!_hasSmsPermission && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("SMS and Phone permissions are required")),
        );
      }
    } catch (e) {
      debugPrint("Permission error: $e");
    }
  }

  Future<void> _sendSelectedMessages() async {
    if (!_hasSmsPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please grant SMS permissions first")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int successCount = 0;
    int failCount = 0;

    try {
      for (int index in _selectedIndexes) {
        final item = messageList[index];
        final phone = item['phone']!;
        final message = item['message']!;

        // Validate phone number
        if (phone.isEmpty || !RegExp(r'^[0-9+]+$').hasMatch(phone)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Invalid phone number: $phone")),
            );
          }
          failCount++;
          continue;
        }

        try {
          // Try sending with another_telephony first
          await _telephony.sendSms(
            to: phone,
            message: message,
            subscriptionId: _selectedSimSlot,
          );

          successCount++;
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint("Error sending SMS to $phone: $e");
          failCount++;

          // Fallback to SMS intent
          try {
            await _sendViaSmsIntent(phone, message);
            successCount++;
          } catch (e2) {
            debugPrint("Fallback SMS sending also failed: $e2");
            failCount++;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Sent $successCount messages successfully. Failed: $failCount",
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedIndexes.clear();
        });
      }
    }
  }

  Future<void> _sendViaSmsIntent(String phone, String message) async {
    try {
      await _telephony.sendSms(
        to: phone,
        message: message,
        subscriptionId: _selectedSimSlot,
      );
    } catch (e) {
      debugPrint("Error sending via intent: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message List'),
        actions: [
          if (_hasSmsPermission)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<int>(
                value: _selectedSimSlot,
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                icon: const Icon(Icons.sim_card, color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("SIM 1")),
                  DropdownMenuItem(value: 2, child: Text("SIM 2")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSimSlot = value;
                    });
                  }
                },
              ),
            ),
          if (!_hasSmsPermission)
            IconButton(
              icon: const Icon(Icons.error, color: Colors.red),
              onPressed: _checkAndRequestPermissions,
              tooltip: "Permissions needed",
            ),
          IconButton(
            icon: Icon(
              _useDirectSmsApi ? Icons.send_outlined : Icons.send_to_mobile,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _useDirectSmsApi = !_useDirectSmsApi;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _useDirectSmsApi
                        ? "Using direct SMS API"
                        : "Using SMS intent",
                  ),
                ),
              );
            },
            tooltip: "Toggle sending method",
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasSmsPermission)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red[100],
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text("Permissions Required"),
                  subtitle: const Text("Tap to grant SMS permissions"),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => openAppSettings(),
                  ),
                  onTap: _checkAndRequestPermissions,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                final item = messageList[index];
                final isSelected = _selectedIndexes.contains(index);

                return ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: _hasSmsPermission
                        ? (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedIndexes.add(index);
                              } else {
                                _selectedIndexes.remove(index);
                              }
                            });
                          }
                        : null,
                  ),
                  title: Text(item['message']!),
                  subtitle: Text('To: ${item['phone']}'),
                  onTap: _hasSmsPermission
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndexes.remove(index);
                            } else {
                              _selectedIndexes.add(index);
                            }
                          });
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndexes.isNotEmpty && _hasSmsPermission
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _sendSelectedMessages,
              icon: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading
                  ? "Sending..."
                  : "Send (${_selectedIndexes.length})"),
            )
          : null,
    );
  }
}
