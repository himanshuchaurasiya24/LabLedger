// // Add this method to your AddBillScreen class to properly handle navigation results

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:labledger/providers/bills_provider.dart';

// class AddBillScreen extends ConsumerStatefulWidget {
//   final Bill? billData;
  
//   const AddBillScreen({super.key, this.billData});

//   @override
//   ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
// }

// class _AddBillScreenState extends ConsumerState<AddBillScreen> {
//   // ... your existing code ...

//   // Method to handle bill creation
//   Future<void> _createBill() async {
//     try {
//       // Your bill creation logic using createBillProvider
//       await ref.read(createBillProvider(newBill).future);
      
//       // Navigate back with success result
//       if (mounted) {
//         Navigator.of(context).pop(true); // Return true to indicate success
//       }
//     } catch (e) {
//       // Handle error
//       debugPrint("Error creating bill: $e");
      
//       // Show error message to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to create bill: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Method to handle bill update
//   Future<void> _updateBill() async {
//     try {
//       // Your bill update logic using updateBillProvider
//       await ref.read(updateBillProvider(updatedBill).future);
      
//       // Navigate back with success result
//       if (mounted) {
//         Navigator.of(context).pop(true); // Return true to indicate success
//       }
//     } catch (e) {
//       // Handle error
//       debugPrint("Error updating bill: $e");
      
//       // Show error message to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to update bill: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Method to handle bill deletion
//   Future<void> _deleteBill(int billId) async {
//     try {
//       // Your bill deletion logic using deleteBillProvider
//       await ref.read(deleteBillProvider(billId).future);
      
//       // Navigate back with success result
//       if (mounted) {
//         Navigator.of(context).pop(true); // Return true to indicate success
//       }
//     } catch (e) {
//       // Handle error
//       debugPrint("Error deleting bill: $e");
      
//       // Show error message to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to delete bill: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) {
//         // Return false to indicate no changes were made if user just backs out
//         Navigator.of(context).pop(false);
//         // return false;
//       },
//       child: Scaffold(
//         // ... your existing UI code ...
        
//         // In your save/submit buttons, call the appropriate methods:
//         // For create: onPressed: _createBill,
//         // For update: onPressed: _updateBill,
//         // For delete: onPressed: () => _deleteBill(widget.billData!.id!),
//       ),
//     );
//   }
// }