void _invalidateReportCache(WidgetRef ref, int billId) {
  // This will cause the UI to refetch the report status for the bill
  ref.invalidate(getReportForBillProvider(billId));
  // Also, invalidate the main bill list to update the reportUrl
  ref.invalidate(billsProvider); 
}