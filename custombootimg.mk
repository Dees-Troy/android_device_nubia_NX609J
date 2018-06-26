
SIGN_PATH := device/nubia/NX609J/sign/

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(MINIGZIP) \
		$(recovery_uncompressed_ramdisk) \
		$(recovery_kernel)
	@echo ----- Compressing recovery ramdisk ------
	$(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) | $(MINIGZIP) > $(recovery_ramdisk)
	@echo ----- Making recovery image ------
	$(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	@echo ----- Signing recovery image -------- $@
	java -Xmx512M -jar $(SIGN_PATH)BootSignature.jar /recovery $@ $(SIGN_PATH)verity.pk8 $(SIGN_PATH)verity.x509.pem $@
	@echo ----- Made recovery image -------- $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)


$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) --output $@
	@echo ----- Signing boot image -------- $@
	java -Xmx512M -jar $(SIGN_PATH)BootSignature.jar /boot $@ $(SIGN_PATH)verity.pk8 $(SIGN_PATH)verity.x509.pem $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
