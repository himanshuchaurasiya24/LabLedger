import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HoverScaleContainer extends StatefulWidget {
  final double width;
  final double height;
  final Doctor doctor;

  const HoverScaleContainer({
    required this.width,
    required this.height,
    required this.doctor,
    super.key,
  });

  @override
  State<HoverScaleContainer> createState() => _HoverScaleContainerState();
}

class _HoverScaleContainerState extends State<HoverScaleContainer> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => scale = 1.1),
      onExit: (_) => setState(() => scale = 1.0),
      child: Center(
        // 👈 Center it inside its grid cell
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width:
                widget.width *
                0.92, // 👈 Slightly smaller base width to allow scaling up
            height: widget.height * 0.92,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
              // boxShadow: [
              //   if (scale > 1.0)
              //     BoxShadow(
              //       // color: Colors.black26,
              //       blurRadius: 10,
              //       offset: Offset(0, 4),
              //     ),
              // ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.doctor.firstName!} ${widget.doctor.lastName!}",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "${widget.doctor.hospitalName!}, ${widget.doctor.phoneNumber!}\n${widget.doctor.address!}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Visibility(
                    visible: scale > 1.0,
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customChip(
                              height: 30,
                              width: 126,
                              chipColor: Colors.green[600]!,
                              backgroundColor: Colors.green[100]!,
                              chipTitle:
                                  "ULTRASOUND ${widget.doctor.ultrasoundPercentage}",
                            ),
                            customChip(
                              width: 126,
                              height: 30,
                              chipColor: Colors.purple[600]!,
                              backgroundColor: Colors.purple[100]!,
                              chipTitle:
                                  "PATHOLOGY ${widget.doctor.pathologyPercentage}",
                            ),
                            customChip(
                              width: 126,
                              height: 30,
                              chipColor: Colors.red[600]!,
                              backgroundColor: Colors.red[100]!,
                              chipTitle:
                                  "FRANCHISE ${widget.doctor.franchiseLabPercentage}",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            customChip(
                              width: 126,
                              height: 30,
                              chipColor: Colors.red[600]!,
                              backgroundColor: Colors.red[100]!,
                              chipTitle: "ECG ${widget.doctor.ecgPercentage}",
                            ),
                            customChip(
                              width: 126,
                              height: 30,
                              chipColor: Colors.red[600]!,
                              backgroundColor: Colors.red[100]!,
                              chipTitle:
                                  "X-RAY ${widget.doctor.xrayPercentage}",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customChipButton(
                              onTap: () {
                                //
                              },
                              iconVisible: true,
                              iconWidget: Icon(
                                LucideIcons.fileText,
                                color: Colors.green[600]!,
                              ),
                              height: 30,
                              width: 130,
                              chipColor: Colors.green[600]!,
                              backgroundColor: Colors.green[100]!,
                              chipTitle: "View Referals",
                            ),
                            customChipButton(
                              onTap: () {
                                //
                              },
                              iconVisible: true,
                              iconWidget: Icon(
                                LucideIcons.edit,
                                color: Colors.blue[600]!,
                              ),
                              height: 30,
                              chipColor: Colors.blue[600]!,
                              backgroundColor: Colors.blue[100]!,
                              chipTitle: "Edit",
                            ),
                            // const SizedBox(width: 10),
                            customChipButton(
                              onTap: () {
                                //
                              },
                              iconVisible: true,
                              iconWidget: Icon(
                                LucideIcons.delete,
                                color: Colors.red[600]!,
                              ),
                              height: 30,
                              chipColor: Colors.red[600]!,
                              backgroundColor: Colors.red[100]!,
                              chipTitle: "Delete",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
