import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: player.isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                )
              : null,
          border: Border.all(
            color: player.isSelected 
                ? AppColors.primary 
                : Colors.grey.shade200,
            width: player.isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: player.isSelected 
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: player.isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          child: Stack(
            children: [
              // 선택 표시
              if (player.isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              
              // 메인 콘텐츠
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 아바타 (길게 눌러서 변경 가능)
                    GestureDetector(
                      onLongPress: onEdit,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: player.isSelected 
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.2),
                                    AppColors.secondary.withValues(alpha: 0.15),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade50,
                                    Colors.grey.shade100,
                                  ],
                                ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: player.isSelected 
                                ? AppColors.primary 
                                : Colors.grey.shade300,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: player.isSelected 
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            player.avatarPath,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 플레이어 이름
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: player.isSelected 
                            ? AppColors.primary 
                            : AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // 액션 버튼들 (편집, 삭제)
              if (onEdit != null || onDelete != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade700],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 6),
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade700],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}