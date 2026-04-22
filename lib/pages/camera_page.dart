import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _picked = [];

  // ── Capture photo via real camera ─────────────────────────────────────────
  Future<void> _takePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file != null) {
      setState(() => _picked.add(file));
      _showSnack('Photo captured!');
    }
  }

  // ── Pick from gallery ─────────────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) {
      setState(() => _picked.addAll(files));
      _showSnack('${files.length} photo(s) added');
    }
  }

  // ── Record video via real camera ───────────────────────────────────────────
  Future<void> _recordVideo() async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file != null) {
      setState(() => _picked.add(file));
      _showSnack('Video recorded!');
    }
  }

  // ── Pick video from gallery ────────────────────────────────────────────────
  Future<void> _pickVideoFromGallery() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _picked.add(file));
      _showSnack('Video added');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _removeItem(int index) => setState(() => _picked.removeAt(index));

  void _done() {
    Navigator.of(context).pop(_picked.map((f) => f.path).toList());
  }

  bool _isVideo(XFile f) {
    final ext = f.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kBgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kNavy),
          onPressed: () => Navigator.of(context).pop(<String>[]),
        ),
        title: Text('Attach Evidence', style: GoogleFonts.playfairDisplay(color: kNavy, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          if (_picked.isNotEmpty)
            TextButton(
              onPressed: _done,
              child: Text(
                'Done (${_picked.length})',
                style: const TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kRed.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kRed.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: kRed, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Capture photos/videos as evidence. '
                      'Max 5 attachments. All media is stored locally.',
                      style: TextStyle(fontSize: 11, color: kRed, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Section: Camera ────────────────────────────────────────────
            const _Label(text: 'Camera'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BigActionTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    sublabel: 'Open camera',
                    color: kOrange,
                    bgColor: const Color(0xFFFFF3E0),
                    onTap: _picked.length < 5 ? _takePhoto : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigActionTile(
                    icon: Icons.videocam_rounded,
                    label: 'Record Video',
                    sublabel: 'Up to 5 min',
                    color: kRed,
                    bgColor: const Color(0xFFFFEEEE),
                    onTap: _picked.length < 5 ? _recordVideo : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ── Section: Gallery ───────────────────────────────────────────
            const _Label(text: 'Gallery'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BigActionTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Pick Photos',
                    sublabel: 'Select multiple',
                    color: const Color(0xFF2255CC),
                    bgColor: const Color(0xFFE8F0FF),
                    onTap: _picked.length < 5 ? _pickFromGallery : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigActionTile(
                    icon: Icons.video_library_rounded,
                    label: 'Pick Video',
                    sublabel: 'From gallery',
                    color: kGreen,
                    bgColor: const Color(0xFFEDF7ED),
                    onTap: _picked.length < 5 ? _pickVideoFromGallery : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Attached files ─────────────────────────────────────────────
            if (_picked.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Label(text: 'Attached Files'),
                  Text(
                    '${_picked.length}/5',
                    style: const TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _picked.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final f = _picked[i];
                  final isVid = _isVideo(f);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isVid
                                ? kRed.withOpacity(0.1)
                                : kOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isVid
                                ? Icons.videocam_rounded
                                : Icons.image_rounded,
                            color: isVid ? kRed : kOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kNavy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isVid ? 'Video file' : 'Image file',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: kTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeItem(i),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kRed.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: kRed,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Done button ──────────────────────────────────────────────
              GestureDetector(
                onTap: _done,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kRed.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attach ${_picked.length} File(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── Empty state ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder, style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: kTextLight,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No files attached yet',
                      style: TextStyle(fontSize: 13, color: kTextMuted),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Use buttons above to add photos or videos',
                      style: TextStyle(fontSize: 11, color: kTextLight),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Big Action Tile ──────────────────────────────────────────────────────────
class _BigActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _BigActionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFEEEEEE) : bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: disabled ? kBorder : color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: disabled ? kBorder : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: disabled ? kTextMuted : color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: disabled ? kTextMuted : kNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                disabled ? 'Max 5 reached' : sublabel,
                style: const TextStyle(fontSize: 10, color: kTextMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kNavy,
      ),
    );
  }
}
