import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/message_provider.dart';
import 'package:labledger/screens/bills/message/local_sms_gateway_service.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class BillMessageService {
  const BillMessageService();

  Future<void> send({
    required BuildContext context,
    required WidgetRef ref,
    required Bill bill,
    required void Function(String title, String message) showErrorDialog,
    required void Function(String message) showSuccessMessage,
  }) async {
    if (bill.id == null) return;
    final gateway = ref.read(messageNotifierProvider);

    final payload = await ref.read(sendBillMessageProvider(bill.id!).future);
    final secureReportUrl = payload['secure_report_url']?.toString();
    final messageText = buildBillMessageText(bill, secureReportUrl, ref);
    final phoneNumber = bill.patientPhoneNumber ?? '';

    if (gateway == MessagePlatform.localSmsGateway) {
      await sendLocalSmsGatewayMessage(
        ref: ref,
        phoneNumber: phoneNumber,
        message: messageText,
      );
      await _markBillMessageSent(ref, bill.id!);
      if (context.mounted) {
        showSuccessMessage('Message sent through local SMS gateway');
      }
      return;
    }

    final encodedText = Uri.encodeComponent(messageText);
    final digitsOnlyPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final targetUri = gateway == MessagePlatform.whatsapp
        ? Uri.parse('whatsapp://send?phone=$digitsOnlyPhone&text=$encodedText')
        : Uri.parse(
            'https://web.whatsapp.com/send?phone=$digitsOnlyPhone&text=$encodedText',
          );

    final canOpen = await canLaunchUrl(targetUri);
    if (canOpen) {
      await launchUrl(targetUri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      final shouldMarkSent = await _confirmMessageSentAfterWhatsappLaunch(
        context,
        gateway,
      );
      if (shouldMarkSent == true) {
        await _markBillMessageSent(ref, bill.id!);
      }
    } else {
      showErrorDialog(
        'Cannot Open WhatsApp',
        'WhatsApp could not be opened on this device.',
      );
    }
  }

  Future<void> _markBillMessageSent(WidgetRef ref, int billId) async {
    await ref.read(markBillMessageSentProvider(billId).future);
    ref.invalidate(singleBillProvider(billId));
  }

  Future<bool?> _confirmMessageSentAfterWhatsappLaunch(
    BuildContext context,
    MessagePlatform gateway,
  ) {
    if (!context.mounted ||
        (gateway != MessagePlatform.whatsapp &&
            gateway != MessagePlatform.whatsappWebUi)) {
      return Future.value(false);
    }

    return showCustomConfirmationDialog(
      context: context,
      title: 'Message sent?',
      message: gateway == MessagePlatform.whatsapp
          ? 'Was the patient messaged on WhatsApp?'
          : 'Was the patient messaged on WhatsApp Web UI?',
      isDeleteOption: false,
      showWarningIcon: false,
      cancelLabel: 'Not Yet',
      confirmLabel: 'Mark Sent',
    );
  }
}
String buildBillMessageText(Bill bill, String? secureReportUrl, WidgetRef ref) {
  String statusSuffix({
    required String fullyPaid,
    required String partiallyPaid,
    required String unpaid,
  }) {
    switch (bill.billStatus) {
      case 'Fully Paid':
        return fullyPaid;
      case 'Partially Paid':
        return partiallyPaid;
      default:
        return unpaid;
    }
  }

  final String by =
      '${bill.testDoneBy!['first_name']} ${bill.testDoneBy!['last_name']}';
  final String center =
      '${bill.centerDetail!['center_name']}, ${bill.centerDetail!['address']}';
  final String amount = '₹${bill.totalAmount}';
  final String status = bill.billStatus;
  final String name = bill.patientName;

  final lines = <String>[
    // 1. Original
    'Hello $name\nI\'m $by from $center. Your bill amount is $amount ($status). ${statusSuffix(fullyPaid: 'Your payment has been received in full. Thank you!', partiallyPaid: 'A partial payment has been received. Kindly clear the remaining balance at your earliest convenience.', unpaid: 'We kindly request you to make the payment at your earliest convenience.')}',

    // 2. Formal & Professional
    'Dear $name,\nI am $by from $center. Your bill of $amount is currently $status. ${statusSuffix(fullyPaid: 'Thank you for settling your bill promptly. We appreciate your trust in us.', partiallyPaid: 'We have received a partial payment. Please arrange to clear the outstanding balance at the earliest.', unpaid: 'We request you to kindly complete the payment to avoid any inconvenience.')}',

    // 3. Warm & Friendly
    'Hi $name!\nI\'m $by from $center. Hope you\'re feeling better! Your bill of $amount is currently $status. ${statusSuffix(fullyPaid: 'Great news — you\'re all settled! Thank you so much.', partiallyPaid: 'You\'re almost there! Just a little balance remaining — feel free to reach out if you need help.', unpaid: 'No worries — just give us a heads-up when you\'re ready to make the payment!')}',

    // 4. Bullet Summary
    'Hello $name,\nHere\'s your billing summary from $center:\n• Amount: $amount\n• Status: $status\nPrepared by $by. ${statusSuffix(fullyPaid: 'Your account is fully settled. Thank you!', partiallyPaid: 'A partial amount has been received. Please clear the remaining balance at your earliest.', unpaid: 'Kindly make the payment at your earliest convenience. Contact us for any queries.')}',

    // 5. Empathetic Tone
    'Dear $name,\nI hope this message finds you in good health. I\'m $by from $center. Your bill of $amount is currently $status. ${statusSuffix(fullyPaid: 'We are glad to confirm your payment is complete. Thank you for your trust in us.', partiallyPaid: 'We understand and appreciate your partial payment. Please settle the remaining amount when convenient.', unpaid: 'We understand healthcare costs can be a concern. Please reach out to us if you need any assistance with the payment.')}',

    // 6. Short & Direct
    'Hi $name,\nYour bill of $amount ($status) from $center has been issued by $by. ${statusSuffix(fullyPaid: 'All clear — thank you for your payment!', partiallyPaid: 'Please arrange for the remaining balance at your earliest.', unpaid: 'Kindly complete the payment at your earliest convenience.')}',

    // 7. Tabular Style
    'Hello $name,\nBilling Details:\nCenter : $center\nAmount : $amount\nStatus : $status\nBy     : $by. ${statusSuffix(fullyPaid: '\nYour account is fully settled. Thank you!', partiallyPaid: '\nA partial payment has been received. Please clear the outstanding balance.', unpaid: '\nKindly make the payment at your earliest convenience.')}',

    // 8. Gratitude-first
    'Dear $name,\nThank you for choosing $center. I\'m $by and your bill of $amount has been processed. Status: $status. ${statusSuffix(fullyPaid: 'We\'re delighted to confirm your full payment. We look forward to serving you again.', partiallyPaid: 'We acknowledge your partial payment. A balance remains — please settle it at your convenience.', unpaid: 'We kindly request you to complete the payment to keep your account up to date.')}',

    // 9. Action-oriented
    'Hello $name,\nYour bill of $amount from $center is now $status. ${statusSuffix(fullyPaid: 'No further action is needed. Thank you for your prompt payment!', partiallyPaid: 'Please take a moment to clear the remaining balance. Contact $by for assistance.', unpaid: 'Please take a moment to complete the payment. For assistance, contact $by.')}',

    // 10. Formal Notification (index 9)
    'BILLING NOTIFICATION\nDear $name,\nThis is an official billing notice from $center.\nTotal Amount : $amount\nStatus       : $status\nIssued by    : $by. ${statusSuffix(fullyPaid: '\nYour account is fully settled. No further action required.', partiallyPaid: '\nA partial payment has been recorded. Kindly clear the outstanding balance at your earliest.', unpaid: '\nPlease arrange for payment at your earliest convenience to avoid any delays.')}',

    // 11. Reassuring Tone
    'Hi $name,\nI\'m $by from $center. Your bill stands at $amount and the current status is $status. ${statusSuffix(fullyPaid: 'Everything is in order. Thank you for your payment!', partiallyPaid: 'We appreciate your partial payment. Our team is happy to help you with the remaining balance.', unpaid: 'We\'re happy to guide you through the payment process. Please don\'t hesitate to reach out.')}',

    // 12. Concise Professional
    'Dear $name,\nYour bill of $amount ($status) has been issued by $by at $center. ${statusSuffix(fullyPaid: 'Thank you for your full payment.', partiallyPaid: 'Kindly settle the remaining amount at the earliest.', unpaid: 'Please make the payment at your earliest convenience.')}',

    // 13. Summary + CTA
    'Hello $name,\nYour bill of $amount from $center is $status. ${statusSuffix(fullyPaid: 'Your payment is complete — thank you! No further action is needed.', partiallyPaid: 'To clear the remaining balance or raise a query, please get in touch with $by.', unpaid: 'To proceed with payment or raise a query, please get in touch with $by.')}',

    // 14. Gentle Reminder
    'Dear $name,\nThis is a message from $by at $center regarding your bill of $amount. Current status: $status. ${statusSuffix(fullyPaid: 'Your account is clear. We sincerely thank you for your timely payment.', partiallyPaid: 'This is a gentle reminder to clear the remaining balance at your earliest convenience.', unpaid: 'This is a gentle reminder to kindly make the payment at your earliest convenience. We appreciate your cooperation.')}',

    // 15. Trust-building
    'Hi $name,\nI\'m $by from $center. We believe in complete transparency — your bill stands at $amount. Status: $status. ${statusSuffix(fullyPaid: 'Your trust means everything to us. Thank you for completing the payment.', partiallyPaid: 'We appreciate your partial payment and trust you will clear the balance soon.', unpaid: 'We assure you of our full support. Please reach out if you need assistance with the payment.')}',

    // 16. Multi-line Structured
    'Dear $name,\nWe hope your experience at $center was satisfactory.\nYour bill of $amount is currently $status. ${statusSuffix(fullyPaid: '\nYour account is fully settled. Thank you for choosing us — we look forward to serving you again.', partiallyPaid: '\nKindly clear the remaining balance at your earliest. For queries, reach out to $by.', unpaid: '\nKindly make the payment at your earliest. For queries, reach out to $by.')}',

    // 17. Minimal Formal
    'Dear $name,\nA bill of $amount ($status) has been issued by $center. Reference: $by. ${statusSuffix(fullyPaid: 'No further action required. Thank you.', partiallyPaid: 'Kindly settle the outstanding balance at your earliest.', unpaid: 'Please make the payment at your earliest convenience.')}',

    // 18. Personal & Caring
    'Hello $name,\nI personally wanted to reach out. I\'m $by from $center. Your bill of $amount is $status. ${statusSuffix(fullyPaid: 'We\'re so glad everything is sorted. Take care and stay healthy!', partiallyPaid: 'We appreciate your effort. Please don\'t hesitate to reach out regarding the remaining balance — we\'re here to help.', unpaid: 'Please don\'t hesitate to get in touch — we\'re always ready to help with the payment.')}',

    // 19. Verification Style
    'Dear $name,\nYour billing record at $center has been verified by $by. Total amount: $amount. Status: $status. ${statusSuffix(fullyPaid: 'Your account is fully cleared. Thank you for your prompt payment.', partiallyPaid: 'A partial payment has been recorded. Please contact us to clear the remaining balance.', unpaid: 'Please contact us if you notice any discrepancies or need assistance with the payment.')}',

    // 20. Closing with Support
    'Hi $name,\nI\'m $by from $center. Your bill of $amount is now $status. ${statusSuffix(fullyPaid: 'You\'re all set! Thank you for your payment. We hope to see you again.', partiallyPaid: 'Should you require a payment plan for the remaining balance, our team is happy to assist you at any time.', unpaid: 'Should you require a payment plan or detailed breakdown, our team is happy to assist you at any time.')}',
  ];

  final gateway = ref.read(messageNotifierProvider);
  final List<String> line;
  if (gateway == MessagePlatform.localSmsGateway) {
    final random = Random();
    line = [lines[random.nextInt(lines.length)]];
  } else {
    line = [lines[9]];
  }

  if (secureReportUrl != null &&
      secureReportUrl.isNotEmpty &&
      bill.billStatus == 'Fully Paid') {
    line.add(
      'You can download your report by visiting here:\n$secureReportUrl.\nPlease keep this link safe as it is one time use only and auto-expires after 6 hrs.',
    );
  }
  return line.join('\n');
}
