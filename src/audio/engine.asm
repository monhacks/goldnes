_InitSound:
	PHP
	PHA
	PHX
	PHY
@ClearAPU:
	JSR ClearChannels
@ClearZeroPage:
	TYA
	LDY #zAudioEnd - zAudio
-	DEY
	STA zAudio, Y
	BNE -
@ClearInternal:
	LDY #CHANNEL_STRUCT_LENGTH * 5
-	DEY
	STA iChannel1, Y
	STA iChannel6, Y
	BNE -
	PLY
	PLX
	PLA
	PLP
	RTS

PreserveIDRestart:
	LDA zMusicSilenceID
	PHA
	JSR _InitSound
	PLA
	STA zMusicSilenceID
	RTS

MusicOn:
	LDA #1
	STA zMusicPlaying
	LDA #$0f
	STA rMIX
	RTS

MusicOff:
	LDA #0
	STA zMusicPlaying
	STA rMIX
	RTS

_UpdateSound:
	; no use updating audio if it's not playing
	LDA zMusicPlaying
	REQ
	; start at ch1
	LDA #0
	STA zCurChannel
	STA zSoundOutput ; just
	STA zSoundOutput + 1 ; off
@Loop:
	JSR UpdateTrackPointer
	; is the channel active?
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	LSR A
	BCS @run
	JMP @NextChannel
@run:
	; check time left in the current note
	LDY #CHANNEL_NOTE_DURATION
	LDA (zCurTrackAudioPointer), Y
	CMP #2 ; 1 or 0?
	BCC @NoteOver
	SBC #1
	STA (zCurTrackAudioPointer), Y
	BNE @ContinueSoundUpdate
@NoteOver:
	; reset vibrato delay
	LDY #CHANNEL_VIBRATO_PREAMBLE
	LDA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_VIBRATO_COUNTER
	STA (zCurTrackAudioPointer), Y
	; turn vibrato off for now
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_PITCH_SLIDE
	STA (zCurTrackAudioPointer), Y
	; get next note
	JSR ParseMusic
@ContinueSoundUpdate:
	JSR ApplyEnvLength
	JSR ApplyPitchSlide
	; pitch sweep
	LDY #CHANNEL_SWEEP
	LDA (zCurTrackAudioPointer), Y
	STA zCurTrackPitchSweep
	; duty cycle
	LDY #CHANNEL_DUTY_CYCLE
	LDA (zCurTrackAudioPointer), Y
	; volume envelope
	INY
	ORA (zCurTrackAudioPointer), Y
	STA zCurTrackVolumeEnvAndDuty
	; frequency
	INY
	LDA (zCurTrackAudioPointer), Y
	STA zCurTrackRawPitch
	INY
	LDA (zCurTrackAudioPointer), Y
	STA zCurTrackRawPitch + 1
	; vibrato, envelope, pitch, chorus, etc
	JSR GeneralHandler
	JSR HandleNoise
	JSR HandleDPCM
	; turn off music when playing sfx?
	LDA zSFXPriority
	BEQ @Next
	; are we in a sfx channel right now?
	LDA zCurChannel
	CMP #NUM_MUSIC_CHANS
	BCS @Next
	; are any sfx channels active?
	; if so, mute
	LDY #CHANNEL_FLAGS1
	LDA iChannel6, Y
	ORA iChannel7, Y
	ORA iChannel8, Y
	ORA iChannel9, Y
	ORA iChannel10, Y
	LSR A
	BCC @Next
	LDY #CHANNEL_NOTE_FLAGS
	LDA #1 << NOTE_REST
	ORA (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
@Next:
	; are we in a sfx channel right now?
	LDA zCurChannel
	CMP #NUM_MUSIC_CHANS
	BCS @SFXChannel
	LDY #CHANNEL_NOTE_FLAGS
	JSR FetchSFXEquivalent
	LSR A
	BCS @SoundChannelOn
@SFXChannel:
	JSR UpdateChannels
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	LSR A
	ROR zSoundOutput
	LDA (zCurTrackAudioPointer), Y
	LSR A
	ROR zSoundOutput + 1
@SoundChannelOn:
	; clear note flags
	LDY #CHANNEL_NOTE_FLAGS
	LDA #0
	STA (zCurTrackAudioPointer), Y
@NextChannel:
	; next channel
	INC zCurChannel
	LDA zCurChannel
	CMP #NUM_CHANNELS ; are we done?
	BEQ +
	JMP @Loop
+	LDA zSoundOutput
	AND #$e0
	LDX #3
-	ASL A
	ROL zSoundOutput + 1
	DEX
	BNE -
	JSR PlayDanger
	JSR SilenceMusic
	RTS

UpdateChannels:
	LDA zCurChannel
	ASL A
	TAY
	LDX @ChannelFunctionPointers, Y
	INY
	LDA @ChannelFunctionPointers, Y
	DEX
	CPX #$FF
	BNE @NoCarry
	CLC
	SBC #0
@NoCarry:
	PHA
	PHX
	RTS

@ChannelFunctionPointers:
	.dw @Ch1
	.dw @Ch2
	.dw @Ch3
	.dw @Ch4
	.dw @Ch5
	.dw @Ch6
	.dw @Ch7
	.dw @Ch8
	.dw @Ch9
	.dw @Ch10

@Ch1:
	LDA zLowHealthAlarm
	RMI
@Ch6:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	TAY
	TSB NOTE_REST
	BNE @Ch1_REST
	TYA
	TSB NOTE_NOISE_SAMPLING
	BNE @Ch1_SMP
	TYA
	TSB NOTE_FREQ_OVERRIDE
	BNE @Ch1_FREQ
	TYA
	TSB NOTE_VIBRATO_OVERRIDE
	BNE @Ch1_VIB
	BEQ @Ch1_Check_Duty
@Ch1_FREQ:
	LDA zCurTrackRawPitch
	STA rNR12
	LDA zCurTrackRawPitch + 1
	ORA #$08
	STA rNR13
	LDA zCurTrackPitchSweep
	STA rNR11
@Ch1_Check_Duty:
	TYA
	TSB NOTE_DUTY_OVERRIDE
	REQ
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR10
	RTS

@Ch1_VIB:
	LDA zCurTrackRawPitch
	STA rNR12
	LDA zCurTrackPitchSweep
	STA rNR11
	TYA
	BNE @Ch1_Check_Duty

@Ch1_REST:
	LDY #0
	LDA #$10
	STA rNR10
	STY rNR11
	STY rNR12
	STY rNR13
	RTS

@Ch1_SMP:
	LDA #$10
	STA rNR10
	LDA zCurTrackRawPitch
	STA rNR12
	LDA zCurTrackRawPitch + 1
	ORA #$08
	STA rNR13
	LDA zCurTrackPitchSweep
	STA rNR11
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR10
	RTS

@Ch2:
@Ch7:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	TAY
	TSB NOTE_REST
	BNE @Ch2_REST
	TYA
	TSB NOTE_NOISE_SAMPLING
	BNE @Ch2_SMP
	TYA
	TSB NOTE_VIBRATO_OVERRIDE
	BNE @Ch2_VIB
	TYA
@Ch2_Check_Duty:
	TSB NOTE_DUTY_OVERRIDE
	REQ
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR20
	RTS

@Ch2_FREQ: ; unreferenced
	LDA zCurTrackRawPitch
	STA rNR22
	LDA zCurTrackRawPitch + 1
	ORA #$08
	STA rNR23
	LDA zCurTrackPitchSweep
	STA rNR21
	RTS

@Ch2_VIB:
	LDA zCurTrackRawPitch
	STA rNR22
	LDA zCurTrackPitchSweep
	STA rNR21
	TYA
	BNE @Ch2_Check_Duty

@Ch2_REST:
	LDY #0
	LDA #$10
	STA rNR20
	STY rNR21
	STY rNR22
	STY rNR23
	RTS

@Ch2_SMP:
	LDA #$10
	STA rNR20
	LDA zCurTrackRawPitch
	STA rNR22
	LDA zCurTrackRawPitch + 1
	ORA #$08
	STA rNR23
	LDA zCurTrackPitchSweep
	STA rNR21
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR20
	RTS

@Ch3:
@Ch8:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	TAY
	TSB NOTE_REST
	BNE @Ch3_REST
	TYA
	TSB NOTE_NOISE_SAMPLING
	BNE @Ch3_SMP
	TYA
	TSB NOTE_VIBRATO_OVERRIDE
	BNE @Ch3_VIB
	RTS

@Ch3_FREQ: ; unreferenced
	LDA zCurTrackRawPitch
	STA rNR32
	LDA zCurTrackRawPitch
	STA rNR33
	RTS

@Ch3_VIB:
	LDA zCurTrackRawPitch
	STA rNR32
	RTS

@Ch3_REST:
	LDY #0
	STY rNR30
	STY rNR32
	STY rNR33
	RtS

@Ch3_SMP:
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR30
	LDA zCurTrackRawPitch
	STA rNR32
	LDA zCurTrackRawPitch + 1
	ORA #$08
	STA rNR33
	RTS

@Ch4:
@Ch9:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	TAY
	TSB NOTE_REST
	BNE @Ch4_REST
	TYA
	TSB NOTE_NOISE_SAMPLING
	BNE @Ch4_SMP
	RTS

@Ch4_REST:
	LDY #0
	LDA #$10
	STA rNR40
	STY rNR42
	STY rNR43
	RTS

@Ch4_SMP:
	LDA zCurTrackVolumeEnvAndDuty
	STA rNR40
	LDA zCurTrackRawPitch
	STA rNR42
	LDA #$08
	STA rNR43
	RTS

@Ch5:
@Ch10:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	TAY
	TSB NOTE_REST
	BNE @Ch5_REST
	TYA
	BMI @Ch5_SMP
	TSB NOTE_NOISE_SAMPLING
	BNE @Ch5_SMP
	RTS

@Ch5_REST:
	LDY #0
	LDA #$0f
	STA rMIX
	STY rNR50
	STY rNR51
	STY rNR52
	STY rNR53
	RTS

@Ch5_SMP:
	LDA #$0f
	STA rMIX
	LDA zDPCMBank
	bsw_c000
	LDA zDPCMPitch
	STA rNR50
	LDA zDPCMOffset
	STA rNR52
	LDA zDPCMLength
	STA rNR53
	LDA #0
	STA rNR51
	LDA #$1f
	STA rMIX
	RTS

_CheckSFX:
	LDY #CHANNEL_FLAGS1
	LDA iChannel6, Y
	ORA iChannel7, Y
	ORA iChannel8, Y
	ORA iChannel9, Y
	ORA iChannel10, Y
	LSR A
	RTS

PlayDanger:
	LDA zLowHealthAlarm
	RPL
	RSB DANGER_ON_F
	TAX
	JSR _CheckSFX
	BCS @Increment
	TXA
	BEQ @Begin
	CMP #16
	BNE @Increment
@Halfway:
	LDA #>DangerSoundLow
	STA zCurTrackAudioPointer + 1
	LDA #<DangerSoundLow
	STA zCurTrackAudioPointer
	BMI @ApplyChannel
@Begin:
	LDA #>DangerSoundHigh
	STA zCurTrackAudioPointer + 1
	LDA #<DangerSoundHigh
	STA zCurTrackAudioPointer
@ApplyChannel:
	LDY #0
	LDA (zCurTrackAudioPointer), Y
	STA rNR10
	INY
	LDA (zCurTrackAudioPointer), Y
	STA rNR12
	INY
	LDA (zCurTrackAudioPointer), Y
	STA rNR13
	INY
@Increment:
	INX
	CPX #30 ; Ending frame
	TXA
	BCS @NoReset
	LDA #0
@NoReset:
	; Make sure the danger sound is kept on
	SSB DANGER_ON_F
	STA zLowHealthAlarm
	; Enable channel 1 in case it's off
	LDA #$7f
	STA rNR11
	LDA #1
	ORA zSoundOutput
	STA zSoundOutput
	LDA #1
	ORA zSoundOutput + 1
	STA zSoundOutput + 1
	RTS

DangerSoundHigh
	.db $86 ; %50 duty, volume ramp counter 7
	.db $97 ; frequency: $097
	.db $08 ; restart sound
	.db $7f ; turn channel on

DangerSoundLow:
	.db $86 ; %50 duty, volume ramp counter 7
	.db $e2 ; frequency: $0e2
	.db $08 ; restart sound
	.db $7f ; turn channel on

SilenceMusic:
; cut music if applicable
; usage:
;	write to zMusicSilence
;	song cuts out after a given time
;	load song id in zMusicSilenceID
;	cut new song in
; notes:
;	max # frames per volume level is $3f
	; cutting out?
	LDA zMusicSilence
	REQ
	LDA zMusicSilenceCount
	BEQ @Update
	DEC zMusicSilenceCount
	RTS
@Update:
	LDA zMusicSilence
	TAX
	AND #$3f
	STA zMusicSilenceCount
	LDY zMusicSilenceOffset
	TXA
	BMI @CutIn
	LDA CutOffMasks, Y
	FAB
	BEQ @NoAudio
	INC zMusicSilenceOffset
	DEX
	BNE @UpdateAudio
	RTS
@NoAudio:
	STA rMIX
	LDA zPlayerState
	CMP PLAYER_BIKE
	BEQ @Bicycle
	JSR PreserveIDRestart
	LDY zMusicSilenceID
	BEQ @Quit
	JSR _PlayMusic
@Quit:
	LDA #0
	STA zMusicSilence
	RTS
@Bicycle:
	JSR PreserveIDRestart
	LDA #0
	STA zMusicSilence
	LDY zMusicSilenceID
	JSR _PlayMusic
	LDA #1 << MUSIC_CUT_IN_F
	ORA zMusicSilence
	STA zMusicSilence
	RTS
@CutIn:
	; are we done?
	TYA
	BEQ @MaxChannels
	DEC zMusicSilenceOffset
	BPL @UpdateAudio
@MaxChannels:
	STA zMusicSilence
	RTS
@UpdateAudio:
	LDA rMIX
	ORA CutOffMasks, Y
	EOR #%11101111
	STA rMIX
	RTS

CutOffMasks:
	.db %11100000
	.db %11101000
	.db %11101010
	.db %11101011
	.db %11101111
	.db %11111111

LoadNote:
	; wait for pitch slide to finish
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_PITCH_SLIDE
	REQ
	; get note duration
	LDY #CHANNEL_NOTE_DURATION
	LDA (zCurTrackAudioPointer), Y
	SEC
	SBC zCurNoteDuration
	BCS @OK
	LDA #1
@OK
	STA zCurNoteDuration
	; get frequency
	LDY #CHANNEL_FREQUENCY + 1
	LDA (zCurTrackAudioPointer), Y
	DEY
	TAX
	LDA (zCurTrackAudioPointer), Y
	; get direction of pitch slide
	LDY #CHANNEL_PITCH_SLIDE_TARGET
	SEC
	SBC (zCurTrackAudioPointer), Y
	INY
	TXA
	SBC (zCurTrackAudioPointer), Y
	BCS @GreaterThan
	LDY #CHANNEL_FLAGS3
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_PITCH_SLIDE_DIR
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_FREQUENCY + 1
	LDA (zCurTrackAudioPointer), Y
	DEY
	TAX
	LDA (zCurTrackAudioPointer), Y
	STA zCurSlideRawPitch
	STX zCurSlideRawPitch + 1
	LDY #CHANNEL_PITCH_SLIDE_TARGET
	LDA (zCurTrackAudioPointer), Y
	SEC
	SBC zCurSlideRawPitch
	STA zCurSlideDistance
	INY
	LDA (zCurTrackAudioPointer), Y
	SBC zCurSlideRawPitch + 1
	STA zCurSlideDistance + 1
	BCS @Resume

@GreaterThan:
	LDY #CHANNEL_FLAGS3
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_PITCH_SLIDE_DIR
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_FREQUENCY + 1
	LDA (zCurTrackAudioPointer), Y
	DEY
	TAX
	LDA (zCurTrackAudioPointer), Y
	; get direction of pitch slide
	LDY #CHANNEL_PITCH_SLIDE_TARGET
	SEC
	SBC (zCurTrackAudioPointer), Y
	INY
	STA zCurSlideDistance
	TXA
	SBC (zCurTrackAudioPointer), Y
	STA zCurSlideDistance + 1
@Resume:
	; zCurSlideDistance = \1 * [zCurNoteDuration] + \2
	; \1 + 1 -> y/a
	; \2 -> x
	LDY #0 ; quotient
@Loop:
	INY
	LDA zCurSlideDistance
	SEC
	SBC zCurNoteDuration
	STA zCurSlideDistance
	BCS @Loop
	LDA zCurSlideDistance
	BEQ @Quit
	DEC zCurSlideDistance + 1
	BPL @Loop
@Quit:
	LDA zCurSlideDistance
	CLC
	ADC zCurNoteDuration
	STA zCurSlideDistance
	TAX
	TYA
	LDY #CHANNEL_PITCH_SLIDE_AMOUNT
	STA (zCurTrackAudioPointer), Y ; quotient
	TXA
	INY
	STA (zCurTrackAudioPointer), Y ; remainder
	LDA #0
	INY
	STA (zCurTrackAudioPointer), Y
	RTS

GeneralHandler:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_DUTY_LOOP
	BEQ @PitchOffset
	LDY #CHANNEL_DUTY_CYCLE_PATTERN
	LDA (zCurTrackAudioPointer), Y
	ROL A
	ROL A
	ADC #0
	STA (zCurTrackAudioPointer), Y
	LDA zCurTrackVolumeEnvAndDuty
	AND #$3f
	StA zCurTrackVolumeEnvAndDuty
	LDA (zCurTrackAudioPointer), Y
	AND #$c0
	ORA zCurTrackVolumeEnvAndDuty
	STA zCurTrackVolumeEnvAndDuty
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_DUTY_OVERRIDE
	STA (zCurTrackAudioPointer), Y
@PitchOffset::
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_PITCH_OFFSET
	BEQ @Vibrato
	LDY #CHANNEL_PITCH_OFFSET
	LDA zCurTrackRawPitch
	CLC
	ADC (zCurTrackAudioPointer), Y
	STA zCurTrackRawPitch
	INY
	LDA zCurTrackRawPitch + 1
	ADC (zCurTrackAudioPointer), Y
	STA zCurTrackRawPitch + 1
@Vibrato:
	; is vibrato on?
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_VIBRATO ; vibrato
	BEQ @Quit
	; is vibrato active for this note yet?
	; is the delay over?
	LDY #CHANNEL_VIBRATO_COUNTER
	LDA (zCurTrackAudioPointer), Y
	BNE @SubExit
	; is the extent nonzero?
	LDY #CHANNEL_VIBRATO_DEPTH
	LDA (zCurTrackAudioPointer), Y
	BEQ @Quit
	; save it for later
	STA zCurTrackTemp
	; is it time to toggle vibrato up/down?
	LDY #CHANNEL_VIBRATO_TIMER
	LDA (zCurTrackAudioPointer), Y
	AND #$0f ; count
	BEQ @Toggle
	LDA (zCurTrackAudioPointer), Y
@SubExit:
	SEC
	SBC #1
	STA (zCurTrackAudioPointer), Y
	RTS
@Toggle:
	; refresh count
	LDA (zCurTrackAudioPointer), Y
	TAX
	LDA (zCurTrackAudioPointer), Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA (zCurTrackAudioPointer), Y
	TXA
	ORA (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	; get pitch
	LDX zCurTrackRawPitch
	; toggle vibrato up/down
	LDY #CHANNEL_FLAGS3
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_VIBRATO_DIR
	BEQ @Down
; up
	; vibrato down
	FSB SOUND_VIBRATO_DIR
	STA (zCurTrackAudioPointer), Y
	; get the delay
	LDA zCurTrackTemp
	AND #$0f ; lo
	STA zCurTrackTemp
	TXA
	SEC
	SBC zCurTrackTemp
	BCS @NoCarry
	LDA #0
	BCC @NoCarry
@Down:
	; vibrato up
	FSB SOUND_VIBRATO_DIR
	STA (zCurTrackAudioPointer), Y
	; get the delay
	LDA zCurTrackTemp
	AND #$f0 ; hi
	LSR A
	LSR A
	LSR A
	LSR A ; move it to lo
	STX zCurTrackTemp
	CLC
	ADC zCurTrackTemp
	BCC @NoCarry
	LDA #$ff
@NoCarry:
	STA zCurTrackRawPitch
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_VIBRATO_OVERRIDE
	STA (zCurTrackAudioPointer), Y
@Quit:
	RTS

ApplyPitchSlide:
	; quit if pitch slide inactive
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_PITCH_SLIDE
	REQ
	; zCurSlideRawPitch = Frequency
	LDY #CHANNEL_FREQUENCY
	LDA (zCurTrackAudioPointer), Y
	STA zCurSlideRawPitch
	INY
	LDA (zCurTrackAudioPointer), Y
	STA zCurSlideRawPitch + 1
	; check whether pitch slide is going up or down
	LDY #CHANNEL_FLAGS3
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_PITCH_SLIDE_DIR
	BEQ @Decreasing
	; frequency += [Channel*PitchSlideAmount]
	LDY #CHANNEL_PITCH_SLIDE_AMOUNT
	LDA (zCurTrackAudioPointer), Y
	CLC
	ADC zCurSlideRawPitch
	STA zCurSlideRawPitch
	LDA #0
	ADC zCurSlideRawPitch + 1
	STA zCurSlideRawPitch + 1
	; [Channel*PitchSlideTempo] += [Channel*PitchSlideAmountFraction]
	; if rollover: Frequency += 1
	INY
	LDA (zCurTrackAudioPointer), Y
	INY
	ADC (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	LDA #0
	ADC zCurSlideRawPitch
	STA zCurSlideRawPitch
	LDA #0
	ADC zCurSlideRawPitch + 1
	STA zCurSlideRawPitch + 1
	; Compare the dw at [Channel*PitchSlideTarget] to de.
	; If frequency is greater, we're finished.
	; Otherwise, load the frequency and set two flags.
	LDY #CHANNEL_PITCH_SLIDE_TARGET + 1
	LDA (zCurTrackAudioPointer), Y
	CMP zCurSlideRawPitch + 1
	BCC @FinishedPitchSlide
	DEY
	LDA (zCurTrackAudioPointer), Y
	CMP zCurSlideRawPitch
	BCC @FinishedPitchSlide
	BCS @ContinuePitchSlide

@Decreasing:
	; frequency -= [Channel*PitchSlideAmount]
	LDY #CHANNEL_PITCH_SLIDE_AMOUNT
	LDA (zCurTrackAudioPointer), Y
	SEC
	SBC zCurSlideRawPitch
	STA zCurSlideRawPitch
	LDA #0
	SBC zCurSlideRawPitch + 1
	STA zCurSlideRawPitch + 1
	; [Channel*PitchSlideTempo] *= 2
	; if rollover: Frequency -= 1
	INY
	LDA (zCurTrackAudioPointer), Y
	ASL A
	STA (zCurTrackAudioPointer), Y
	LDA #0
	SBC zCurSlideRawPitch
	STA zCurSlideRawPitch
	LDA #0
	SBC zCurSlideRawPitch + 1
	STA zCurSlideRawPitch + 1
	; Compare the dw at [Channel*PitchSlideTarget] to de.
	; If frequency is lower, we're finished.
	; Otherwise, load the frequency and set two flags.
	LDY #CHANNEL_PITCH_SLIDE_TARGET + 1
	LDA zCurSlideRawPitch + 1
	CLC
	ADC #1
	CMP (zCurTrackAudioPointer), Y
	BCS @FinishedPitchSlide
	DEY
	LDA zCurSlideRawPitch
	CMP (zCurTrackAudioPointer), Y
	BCC @ContinuePitchSlide
@FinishedPitchSlide:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_PITCH_SLIDE
	STA (zCurTrackAudioPointer), Y
	INY
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_PITCH_SLIDE_DIR
	STA (zCurTrackAudioPointer), Y
	RTS

@ContinuePitchSlide:
	LDY #CHANNEL_FREQUENCY
	LDA zCurSlideRawPitch
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zCurSlideRawPitch + 1
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	ORA #1 << NOTE_FREQ_OVERRIDE | 1 << NOTE_DUTY_OVERRIDE
	STA (zCurTrackAudioPointer), Y
	RTS

HandleNoise:
	; is noise sampling on?
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_NOISE ; noise sampling
	REQ
	; are we in a sfx channel?
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS @Next
	; is ch9 on? (noise)
	LDY #CHANNEL_FLAGS1
	LDA iChannel9, Y
	LSR A ; on?
	BCC @Next
	; is ch9 playing noise?
	LDA iChannel9, Y
	TSB SOUND_NOISE
	RNE ; quit if so
@Next:
	LDA zNoiseSampleDelay
	BEQ ReadNoiseSample
	DEC zNoiseSampleDelay
	RTS

ReadNoiseSample:
; sample struct:
;	[wx] [yy] [zz]
;	w: does nothing
;	x: actual duration - 2
;		1 = 3 2 = 4 etc
;	yy: volume envelope
;	zz: frequency

	; [wNoiseSampleAddress]
	; is it empty?
	LDA zNoiseSampleAddress
	ORA zNoiseSampleAddress + 1
	REQ
	LDY #0
	LDA (zNoiseSampleAddress), Y
	INY
	TAX
	INX
	BEQ @Quit
	AND #$0f
	TAX
	INX
	STX zNoiseSampleDelay
	LDA (zNoiseSampleAddress), Y
	INY
	STA zCurTrackVolumeEnvAndDuty
	LDA (zNoiseSampleAddress), Y
	INY
	STA zCurTrackRawPitch
	LDA #0
	STA zCurTrackRawPitch + 1
	TYA
	CLC
	ADC zNoiseSampleAddress
	STA zNoiseSampleAddress
	LDA #0
	ADC zNoiseSampleAddress + 1
	STA zNoiseSampleAddress + 1
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_NOISE_SAMPLING
	STA (zCurTrackAudioPointer), Y
@Quit:
	RTS

HandleDPCM:
	; is DPCM sampling on?
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	ASL A
	RPL
	; are we in a sfx channel?
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS @Next
	; is ch10 on? (DPCM)
	LDY #CHANNEL_FLAGS1
	LDA iChannel10, Y
	LSR A ; on?
	BCC @Next
	; is ch10 playing samples?
	LDA iChannel10, Y
	ASL A
	RMI ; quit if so
@Next:
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	BMI ReadDPCMSample
	RTS

ReadDPCMSample:
; bank, pitch, length, offset
	; [zDPCMAddress]
	; is it empty?
	LDA zDPCMAddress
	ORA zDPCMAddress + 1
	REQ
	LDY #0
	LDA (zDPCMAddress), Y
	INY
	STA zDPCMBank
	LDA (zDPCMAddress), Y
	INY
	STA zDPCMPitch
	LDA (zDPCMAddress), Y
	INY
	STA zDPCMLength
	LDA (zDPCMAddress), Y
	STA zDPCMOffset
	RTS

ParseMusic:
	JSR GetMusicByte
	TAX
	INX
	BEQ @SoundRet
	CMP #FIRST_MUSIC_COMMAND
	BCC @ReadNote
@ReadCommand:
	JSR ParseMusicCommand
	JMP ParseMusic
@ReadNote:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	AND #1 << SOUND_READING_MODE | 1 << SOUND_CRY
	JNE ParseSFXOrCry
	LDA (zCurTrackAudioPointer), Y
	AND #1 << SOUND_NOISE
	JNE GetNoiseSample
	LDA (zCurTrackAudioPointer), Y
	ASL A
	JMI GetDPCMSample
; normal note
	LDA zCurMusicByte
	AND #$0f
	JSR SetNoteDuration
	LDA zCurMusicByte
	LSR A
	LSR A
	LSR A
	LSR A
	BEQ @Rest
	PHA
	LDY #CHANNEL_OCTAVE
	LDA (zCurTrackAudioPointer), Y
	STA zCurTrackTemp
	LDY #CHANNEL_PITCH
	PLA
	STA (zCurTrackAudioPointer), Y
	STA zTempPitch
	JSR GetPitch
	LDY #CHANNEL_FREQUENCY
	LDA zTempRawPitch
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zTempRawPitch + 1
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_NOISE_SAMPLING
	STA (zCurTrackAudioPointer), Y
	JSR @ResetEnv
	JMP LoadNote
@Rest:
	JSR @ResetEnv
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_REST
	STA (zCurTrackAudioPointer), Y
	RTS
@SoundRet:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_SUBROUTINE
	BNE @ReadCommand
	LDA zCurChannel
	CMP #CHAN6
	BCS @Chan6To10
	LDY #CHANNEL_NOTE_FLAGS
	JSR FetchSFXEquivalent
	LSR A
	BCS @OK
@Chan6To10:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_CRY
	JSC nz, ResetCryParams
	; end music
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	CMP #CHAN2
	BCS @OK
	; no sweep
	TAX
	LDA #0
	STA rNR11, X ; sweep = 0
@OK:
	; turn channel off
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_CHANNEL_ON
	STA (zCurTrackAudioPointer), Y
	; note = rest
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_REST
	STA (zCurTrackAudioPointer), Y
	; clear music id, sweep & bank
	LDY #CHANNEL_MUSIC_ID
	LDA #0
	STA (zCurTrackAudioPointer), Y
	INY
	STA (zCurTrackAudioPointer), Y
	INY
	STA (zCurTrackAudioPointer), Y
	RTS
@ResetEnv:
	LDY #CHANNEL_ENV_LENGTH
	LDA (zCurTrackAudioPointer), Y
	AND #$f0
	STA (zCurTrackAudioPointer), Y
REPT 4
	LSR A
ENDR
	AND #$07
	ADC (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	INY
	LDA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_VOLUME_ENVELOPE
	STA (zCurTrackAudioPointer), Y
	RTS

ResetCryParams:
	LDA zCurChannel
	CMP CHAN6
	RNE
	LDA #0
	LDY #CHANNEL_PITCH_OFFSET
	STA iChannel7, Y
	STA iChannel9, Y
	INY
	STA iChannel7, Y
	STA iChannel9, Y
	STA zSFXPriority
	RTS

ParseSFXOrCry:
	; turn noise sampling on
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_NOISE_SAMPLING ; noise sample
	STA (zCurTrackAudioPointer), Y
	; check for DPCM channel
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	CMP #CHAN5
	BCC +
	JMP ParseDPCM
	; update note duration
+	LDA zCurMusicByte
	JSR SetNoteDuration ; top nybble only applied to SFX / cries
	; update volume envelope from next param
	JSR GetMusicByte
	LDY #CHANNEL_VOLUME_ENVELOPE
	STA (zCurTrackAudioPointer), Y
	; update lo frequency from next param
	JSR GetMusicByte
	LDY #CHANNEL_FREQUENCY
	STA (zCurTrackAudioPointer), Y
	; are we on the noise channel? (noise sampling)
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	CMP #CHAN4
	REQ
	; update hi frequency from next param
	JSR GetMusicByte
	LDY #CHANNEL_FREQUENCY + 1
	STA (zCurTrackAudioPointer), Y
	RTS

ParseDPCM:
	LDA zCurMusicByte
	JSR SetNoteDuration
	JSR GetMusicByte
	STA zDPCMBank
	JSR GetMusicByte
	STA zDPCMLength
	JSR GetMusicByte
	STA zDPCMOffset
	RTS

GetNoiseSample:
; load ptr to sample header in zNoiseSampleAddress
	; are we on the noise channel?
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS +
	LDA zCurChannel
+	CMP #CHAN4
	RNE
	; update note duration
	LDA zCurMusicByte
	AND #$0f
	JSR SetNoteDuration
	; check current channel
	LDA zCurChannel
	CMP #NUM_MUSIC_CHANS
	BCS @SFX
	LDY #CHANNEL_FLAGS1
	LDA iChannel9, Y
	LSR A ; is ch9 on? (noise)
	RCS
	LDA zMusicDrumSet
	BPL @Next
@SFX:
	LDA zSFXDrumSet
@Next:
	ASL A
	TAY
	LDA Drumkits_Noise, Y
	STA zNoiseSampleAddress
	INY
	LDA Drumkits_Noise, Y
	STA zNoiseSampleAddress + 1
	LDA zCurMusicByte
	LSR A
	LSR A
	LSR A
	LSR A
	BEQ @Rest
	ASL A
	TAY
	LDA (zNoiseSampleAddress), Y
	TAX
	INY
	LDA (zNoiseSampleAddress), Y
	STX zNoiseSampleAddress
	STA zNoiseSampleAddress + 1
	LDA #0
	STA zNoiseSampleDelay
	RTS
@Rest:
	LDA #0
	STA zNoiseSampleAddress
	STA zNoiseSampleAddress + 1
	RTS

GetDPCMSample:
; load ptr to sample header in zDPCMAddress
	; are we on the last channel?
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS +
	LDA zCurChannel
+	CMP #CHAN5
	RNE
	; update note duration
	LDA zCurMusicByte
	AND #$0f
	JSR SetNoteDuration
	; check current channel
	LDA zCurChannel
	CMP #NUM_MUSIC_CHANS
	BCS @SFX
	LDY #CHANNEL_FLAGS1
	LDA iChannel10, Y
	LSR A ; is ch10 on? (noise)
	RCS
	LDA zMusicDrumSet
	BPL @Next
@SFX:
	LDA zSFXDrumSet
@Next:
	ASL A
	TAY
	LDA Drumkits_DPCM, Y
	STA zDPCMAddress
	INY
	LDA Drumkits_DPCM, Y
	STA zDPCMAddress + 1
	LDA zCurMusicByte
	LSR A
	LSR A
	LSR A
	LSR A
	REQ
	ASL A
	TAY
	LDA (zDPCMAddress), Y
	TAX
	INY
	LDA (zDPCMAddress), Y
	STX zDPCMAddress
	STA zDPCMAddress + 1
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB #NOTE_DELTA_SAMPLING
	STA (zCurTrackAudioPointer), Y
	RTS

ParseMusicCommand:
	; reload command
	LDA zCurMusicByte
	; get command #
	SEC
	SBC #FIRST_MUSIC_COMMAND
	; seek command pointer
	ASL A
	TAY
	LDA MusicCommands, Y
	SEC
	SBC #1
	INY
	TAX
	LDA MusicCommands, Y
	SBC #0
	PHA
	TXA
	PHA
	; jump to the new pointer
	RTS

MusicCommands:
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_NoteType
	.dw Music_Transpose
	.dw Music_Tempo
	.dw Music_DutyCycle
	.dw Music_VolumeEnvelope
	.dw Music_PitchSweep
	.dw Music_DutyCyclePattern
	.dw Music_ToggleMusic
	.dw Music_PitchSlide
	.dw Music_Vibrato
	.dw Music_Staccato
	.dw Music_ToggleDrum
	.dw MusicDummy
	.dw MusicDummy
	.dw Music_PitchOffset
	.dw Music_RelativePitch
	.dw Music_VolumeEnvelopePattern
	.dw Music_TempoRelative
	.dw Music_RestartChannel
	.dw Music_NewSong
	.dw Music_SFXPriorityOn
	.dw Music_SFXPriorityOff
	.dw Music_JumpRAM
	.dw MusicDummy
	.dw Music_SFXToggleDrum
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw Music_SetSoundEvent
	.dw Music_SetCondition
	.dw Music_JumpIf
	.dw Music_Jump
	.dw Music_Loop
	.dw Music_Call
	.dw Music_Ret

MusicDummy:
	RTS

Music_Ret:
	; restored previous pointer
	LDY #CHANNEL_LAST_MUSIC_ADDRESS + 1
	LDA (zCurTrackAudioPointer), Y
	DEY
	PHA
	LDA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_MUSIC_ADDRESS
	STA (zCurTrackAudioPointer), Y
	PLA
	INY
	STA (zCurTrackAudioPointer), Y
	; stack not needed anymore
	INY
	LDA #0
	STA (zCurTrackAudioPointer), Y
	INY
	STA (zCurTrackAudioPointer), Y
	; reset sub flag
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_SUBROUTINE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Call:
	LDY #CHANNEL_MUSIC_ADDRESS
	LDA #2
	CLC
	ADC (zCurTrackAudioPointer), Y
	PHA
	INY
	LDA #0
	ADC (zCurTrackAudioPointer), Y
	LDY #CHANNEL_LAST_MUSIC_ADDRESS + 1
	STA (zCurTrackAudioPointer), Y
	DEY
	PLA
	STA (zCurTrackAudioPointer), Y
	JSR Music_Jump
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_SUBROUTINE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Jump:
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	LDY #CHANNEL_MUSIC_ADDRESS + 1
	STA (zCurTrackAudioPointer), Y
	PLA
	DEY
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Loop:
	JSR GetMusicByte
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	TSB SOUND_LOOPING
	BNE @CheckLoop
	LDX zCurMusicByte
	BEQ @Loop
	DEX
	TXA
	LDY #CHANNEL_LOOP_COUNT
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_LOOPING
	STA (zCurTrackAudioPointer), Y
@CheckLoop:
	LDY #CHANNEL_LOOP_COUNT
	LDA (zCurTrackAudioPointer), Y
	BEQ @SkipPointer
	SEC
	SBC #1
	STA (zCurTrackAudioPointer), Y
@Loop:
	JMP Music_Jump
@SkipPointer:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_LOOPING
	STA (zCurTrackAudioPointer), Y

Music_SkipPointer:
	LDA #2
	LDY #CHANNEL_MUSIC_ADDRESS
	CLC
	ADC (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	INY
	LDA #0
	ADC (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	RTS

Music_SetCondition:
	JSR GetMusicByte
	LDY #CHANNEL_CONDITION
	STA (zCurTrackAudioPointer), Y
	RTS

Music_JumpIf:
	JSR GetMusicByte
	LDY #CHANNEL_CONDITION
	CMP (zCurTrackAudioPointer), Y
	BEQ @Jump
	JMP Music_SkipPointer
@Jump
	JMP Music_Jump

Music_JumpRAM:
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS +
	LDA zCurChannel
+	TAY
	LDA zChannel1JumpCondition, Y
	BNE @Jump
	JMP Music_SkipPointer
@Jump
	JMP Music_Jump

Music_SetSoundEvent:
	LDA #1 << SOUND_EVENT_F
	STA zUnusedF9Flag
	RTS

Music_Staccato:
	JSR GetMusicByte
	LDY #CHANNEL_STACCATO
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_STACCATO
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Vibrato:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_VIBRATO
	STA (zCurTrackAudioPointer), Y
	INY
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_VIBRATO_DIR
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	LDY #CHANNEL_VIBRATO_PREAMBLE
	STA (zCurTrackAudioPointer), Y
	DEY
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	LDY #CHANNEL_VIBRATO_DEPTH
REPT 5
	LSR A
ENDR
	STA zCurTrackTemp
	ADC #0
REPT 4
	ASL A
ENDR
	ORA zCurTrackTemp
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zCurMusicByte
	AND #$0f
	STA zCurTrackTemp
REPT 4
	ASL A
ENDR
	ORA zCurTrackTemp
	STA (zCurTrackAudioPointer), Y
	RTS

Music_PitchSlide:
	JSR GetMusicByte
	STA zCurNoteDuration
	JSR GetMusicByte
REPT 4
	LSR A
ENDR
	STA zCurTrackTemp
	LDA zCurMusicByte
	AND #$0f
	STA zTempPitch
	JSR GetPitch
	LDY #CHANNEL_PITCH_SLIDE_TARGET
	LDA zTempRawPitch
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zTempRawPitch + 1
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_PITCH_SLIDE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_PitchOffset:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_PITCH_OFFSET
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	LDY #CHANNEL_PITCH_OFFSET
	STA (zCurTrackAudioPointer), Y
	PLA
	INY
	STA (zCurTrackAudioPointer), Y
	RTS

Music_RelativePitch:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_RELATIVE_PITCH
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	LDY #CHANNEL_RELATIVE_PITCH
	STA (zCurTrackAudioPointer), Y
	RTS

Music_DutyCyclePattern:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_DUTY_LOOP
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	CLC
REPT 2
	ROR A
	BCC +
	CLC
	ADC #$80
+
ENDR
	LDY #CHANNEL_DUTY_CYCLE_PATTERN
	STA (zCurTrackAudioPointer), Y
	AND #$c0
	LDY #CHANNEL_DUTY_CYCLE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_VolumeEnvelopePattern:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_ENV_SEQUENCE
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	LDY #CHANNEL_ENV_SEQUENCE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_ToggleMusic:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	FSB SOUND_READING_MODE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_ToggleDrum:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	BMI @Off
	TSB SOUND_NOISE
	BEQ @On
@Off:
	LDA iChannel4, Y
	AND #$ff ^ (1 << SOUND_NOISE | 1 << SOUND_DPCM)
	STA iChannel4, Y
	LDA iChannel5, Y
	AND #$ff ^ (1 << SOUND_NOISE | 1 << SOUND_DPCM)
	STA iChannel5, Y
	RTS
@On:
	LDA #1 << SOUND_NOISE
	ORA iChannel4, Y
	STA iChannel4, Y
	LDA #1 << SOUND_DPCM
	ORA iChannel5, Y
	STA iChannel5, Y
	JSR GetMusicByte
	STA zMusicDrumSet
	RTS

Music_SFXToggleDrum:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	AND #1 << SOUND_NOISE | 1 << SOUND_DPCM
	BEQ @On
@Off:
	LDA iChannel9, Y
	AND #$ff ^ (1 << SOUND_NOISE | 1 << SOUND_DPCM)
	STA iChannel9, Y
	LDA iChannel10, Y
	AND #$ff ^ (1 << SOUND_NOISE | 1 << SOUND_DPCM)
	STA iChannel10, Y
	RTS
@On:
	LDA #1 << SOUND_NOISE
	ORA iChannel9, Y
	STA iChannel9, Y
	LDA #1 << SOUND_DPCM
	ORA iChannel10, Y
	STA iChannel10, Y
	JSR GetMusicByte
	STA zSFXDrumSet
	RTS

Music_NoteType:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_ENV_TIMER
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	LDY #CHANNEL_FLAGS2
	TSB SOUND_ENV_TIMER
	ORA (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_NOTE_LENGTH
	LDA zCurMusicByte
	RSB SOUND_ENV_TIMER
	STA (zCurTrackAudioPointer), Y
	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	BCS +
	LDA zCurChannel
+	CMP #CHAN4
	RCS
	JMP Music_VolumeEnvelope

Music_PitchSweep:
	JSR GetMusicByte
	LDY #CHANNEL_SWEEP
	STA (zCurTrackAudioPointer), Y
	RTS

Music_DutyCycle:
	JSR GetMusicByte
	LSR A
	ROR A
	ROR A
	LDY #CHANNEL_DUTY_CYCLE
	STA (zCurTrackAudioPointer), Y
	RTS

Music_VolumeEnvelope:
	LDA #0
	LDY #CHANNEL_ENV_LENGTH
	STA (zCurTrackAudioPointer), Y
	JSR GetMusicByte
	TAX
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	BPL @Store
	TXA
REPT 4
	ASL A
ENDR
	LDY #CHANNEL_ENV_LENGTH
	STA (zCurTrackAudioPointer), Y
	TXA
REPT 4
	LSR A
ENDR
	ORA #$10
	LDY #CHANNEL_VOLUME_ENVELOPE
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_ENV_BACKUP
	STA (zCurTrackAudioPointer), Y
	RTS
@Store:
	TXA
	LDY #CHANNEL_VOLUME_ENVELOPE
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_ENV_BACKUP
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Tempo:
	JSR GetMusicByte
	STA zTempSpeed + 1
	JSR GetMusicByte
	STA zTempSpeed
	JMP SetGlobalTempo

Music_Octave:
	LDY #CHANNEL_OCTAVE
	LDA zCurMusicByte
	AND #$7
	STA (zCurTrackAudioPointer), Y
	RTS

Music_Transpose:
	JSR GetMusicByte
	LDY #CHANNEL_TRANSPOSITION
	STA (zCurTrackAudioPointer), Y
	RTS

Music_TempoRelative:
	JSR GetMusicByte
	STA zTempSpeed
	BMI @Negative
	LDA #0
	BEQ @OK
@Negative:
	LDA #$ff
@OK:
	STA zTempSpeed + 1
	LDY #CHANNEL_TEMPO
	LDA zTempSpeed
	ADC (zCurTrackAudioPointer), Y
	STA zTempSpeed
	LDA zTempSpeed + 1
	ADC (zCurTrackAudioPointer), Y
	STA zTempSpeed + 1
	JMP SetGlobalTempo

Music_SFXPriorityOff:
	LDA #1 << SOUND_PRIORITY_F
	STA zSFXPriority
	RTS

Music_SFXPriorityOn:
	LDA #0
	STA zSFXPriority
	RTS

Music_RestartChannel:
	LDY #CHANNEL_MUSIC_ID
	LDA (zCurTrackAudioPointer), Y
	STA zMusicID
	LDY #CHANNEL_MUSIC_BANK
	LDA (zCurTrackAudioPointer), Y
	STA zMusicBank
	LDA zCurChannel
	PHA
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	STA zCurTrackAudioPointer + 1
	PLA
	STA zCurTrackAudioPointer
	JSR LoadChannel
	JSR StartChannel
	PLA
	STA zCurChannel
	JMP UpdateTrackPointer

Music_NewSong:
	JSR GetMusicByte
	TAY
	LDA zCurChannel
	PHA
	JSR _PlayMusic
	PLA
	STA zCurChannel
	JMP UpdateTrackPointer

GetMusicByte:
	LDY #CHANNEL_MUSIC_BANK
	LDA (zCurTrackAudioPointer), Y
	PHA
	LDY #CHANNEL_MUSIC_ADDRESS
	LDA (zCurTrackAudioPointer), Y
	TAX
	INY
	LDA (zCurTrackAudioPointer), Y
	STA zCurTrackAudioPointer + 1
	STX zCurTrackAudioPointer
	AND #$3f
REPT 5
	LSR A
ENDR
	TAX
	PLA
	JSR _LoadMusicByte
	LDA #1
	ADC zCurTrackAudioPointer
	PHA
	LDA #0
	ADC zCurTrackAudioPointer + 1
	PHA
	JSR UpdateTrackPointer
	LDY #CHANNEL_MUSIC_ADDRESS + 1
	PLA
	STA (zCurTrackAudioPointer), Y
	DEY
	PLA
	STA (zCurTrackAudioPointer), Y
	LDA zCurMusicByte
	RTS

GetPitch:
; input		out
; zCurTrackTemp	zTempRawPitch
; zTempPitch	zTempRawPitch + 1
	LDY #CHANNEL_TRANSPOSITION
	LDA (zCurTrackAudioPointer), Y
REPT 4
	LSR A
ENDR
	CLC
	ADC zCurTrackTemp
	PHA
	LDA (zCurTrackAudioPointer), Y
	AND #$0f
	CLC
	ADC zTempPitch
	ASL A
	TAY
	LDA FrequencyTable, Y
	INY
	STA zTempRawPitch
	LDA FrequencyTable, Y
	STA zTempRawPitch + 1
	PLA
	TAY
@Loop:
	CPY #7
	BCS @OK
	LSR zTempRawPitch + 1
	ROR zTempRawPitch
	INY
	BNE @Loop
@OK:
	LDA zTempRawPitch + 1
	AND #$7
	STA zTempRawPitch + 1
	RTS

SetNoteDuration:
	CLC
	ADC #1
	STA MMC5_Multiplier1
	LDY #CHANNEL_NOTE_LENGTH
	LDA (zCurTrackAudioPointer), Y
	STA MMC5_Multiplier2
	LDA MMC5_Multiplier1
	PHA
	STA MMC5_Multiplier1
	LDY #CHANNEL_TEMPO
	LDA (zCurTrackAudioPointer), Y
	STA MMC5_Multiplier2
	LDY #CHANNEL_NOTE_DURATION + 1
	JSR @Multiply
	DEY
	LDA MMC5_Multiplier2
	ADC #0
	STA (zCurTrackAudioPointer), Y
	PLA
	STA MMC5_Multiplier1
	LDY #CHANNEL_TEMPO + 1
	LDA (zCurTrackAudioPointer), Y
	STA MMC5_Multiplier2
	LDY #CHANNEL_NOTE_DURATION
@Multiply:
	LDA MMC5_Multiplier1
	CLC
	ADC (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	RTS

SetGlobalTempo:
	LDA zTempSpeed
	LDY #CHANNEL_TEMPO
	JSR Tempo
	LDA zTempSpeed + 1
	INY
	JSR Tempo
	LDA #0
	LDY #CHANNEL_NOTE_DURATION + 1
Tempo:
	LDX zCurChannel
	CPX #CHAN6
	BCS @SFX
	STA iChannel1, Y
	STA iChannel2, Y
	STA iChannel3, Y
	STA iChannel4, Y
	STA iChannel5, Y
	RTS
@SFX:
	STA iChannel6, Y
	STA iChannel7, Y
	STA iChannel8, Y
	STA iChannel9, Y
	STA iChannel10, Y
	RTS

StartChannel:
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_CHANNEL_ON	
	STA (zCurTrackAudioPointer), Y
	LDA zMusicHeader
	STA zCurTrackAudioPointer
	LDA zMusicHeader + 1
	STA zCurTrackAudioPointer + 1
	RTS

_PlayMusic:
	JSR MusicOff
	STY zMusicID
	LDA #>Music
	STA zCurTrackAudioPointer + 1
	LDA #<Music
	STA zCurTrackAudioPointer
	JSR AddAudioOffset
	JSR AddAudioOffset
	JSR AddAudioOffset
	LDY #0
	LDA (zCurTrackAudioPointer), Y
	INY
	STA zMusicBank
	LDA (zCurTrackAudioPointer), Y
	INY
	TAX
	LDA (zCurTrackAudioPointer), Y
	STX zCurTrackAudioPointer
	STA zCurTrackAudioPointer + 1
	JSR LoadMusicByte
	ROL A
	ROL A
	ROL A
	ROL A
	AND #$7
@Loop:
	PHA
	JSR LoadChannel
	JSR StartChannel
	PLA
	SEC
	SBC #1
	BPL @Loop
	LDA #0
	STA zUnusedF9Flag
	STA zChannel1JumpCondition
	STA zChannel2JumpCondition
	STA zChannel3JumpCondition
	STA zChannel4JumpCondition
	STA zChannel5JumpCondition
	STA zNoiseSampleAddress
	STA zNoiseSampleAddress + 1
	STA zNoiseSampleDelay
	STA zDPCMAddress
	STA zDPCMAddress + 1
	STA zMusicDrumSet
	JMP MusicOn

_PlayCry:
	JSR MusicOff
	LDA #0
	STA rNR11
	STA rNR21
	LDA #>Cries
	STA zCurTrackAudioPointer + 1
	LDA #<Cries
	STA zCurTrackAudioPointer
	JSR AddAudioOffset
	JSR AddAudioOffset
	JSR AddAudioOffset
	LDY #0
	LDA (zCurTrackAudioPointer), Y
	INY
	STA zMusicBank
	LDA (zCurTrackAudioPointer), Y
	INY
	TAX
	LDA (zCurTrackAudioPointer), Y
	STX zCurTrackAudioPointer
	STA zCurTrackAudioPointer + 1
	JSR LoadMusicByte
	ROL A
	ROL A
	ROL A
	ROL A
	AND #$7
@Loop:
	PHA
	JSR LoadChannel

	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_CRY
	STA (zCurTrackAudioPointer), Y

	INY
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_PITCH_OFFSET
	STA (zCurTrackAudioPointer), Y

	LDY #CHANNEL_PITCH_OFFSET
	LDA zCryPitch
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zCryPitch + 1
	STA (zCurTrackAudioPointer), Y

	LDA zCurChannel
	SEC
	SBC #NUM_MUSIC_CHANS
	CMP #CHAN4
	BCS @Start

	LDY #CHANNEL_TEMPO
	LDA zCryLength
	STA (zCurTrackAudioPointer), Y
	INY
	LDA zCryLength + 1
	STA (zCurTrackAudioPointer), Y
@Start:
	JSR StartChannel
	PLA
	SEC
	SBC #1
	BPL @Loop
	LDA #1 << SOUND_PRIORITY_F
	STA zSFXPriority
	JMP MusicOn

_PlaySFX:
	JSR MusicOff
	LDY #CHANNEL_FLAGS1
	LDA iChannel6, Y
	LSR A
	BCC @Ch7
	ASL A
	STA iChannel6, Y
	LDA #0
	LDX #10
	STX rNR10
	STA rNR12
	STA rNR13
	STA rNR11
	STA zCurTrackPitchSweep
	STA iChannel6 + CHANNEL_SWEEP
@Ch7:
	LDA iChannel7, Y
	LSR A
	BCC @Ch8
	ASL A
	STA iChannel7, Y
	LDA #0
	LDX #10
	STX rNR20
	STA rNR22
	STA rNR23
	STA rNR21
	STA zCurTrackPitchSweep
	STA iChannel7 + CHANNEL_SWEEP
@Ch8:
	LDA iChannel8, Y
	LSR A
	BCC @Ch9
	ASL A
	STA iChannel8, Y
	LDA #0
	STA rNR30
	STA rNR32
	STA rNR33
@Ch9:
	LDA iChannel9, Y
	LSR A
	BCC @Ch10
	ASL A
	STA iChannel9, Y
	LDA #0
	LDX #10
	STX rNR40
	STA rNR42
	STA rNR43
@Ch10:
	LDA iChannel10, Y
	LSR A
	BCC @ChsCleared
	ASL A
	STA iChannel10, Y
	LDA #0
	STA rNR50
	STA rNR52
	STA rNR53
@ChsCleared:
	LDA #>SFX
	STA zCurTrackAudioPointer + 1
	LDA #<SFX
	STA zCurTrackAudioPointer
	JSR AddAudioOffset
	JSR AddAudioOffset
	JSR AddAudioOffset
	LDY #0
	LDA (zCurTrackAudioPointer), Y
	INY
	STA zMusicBank
	LDA (zCurTrackAudioPointer), Y
	INY
	TAX
	LDA (zCurTrackAudioPointer), Y
	STX zCurTrackAudioPointer
	STA zCurTrackAudioPointer + 1
	JSR LoadMusicByte
	ROL A
	ROL A
	ROL A
	ROL A
	AND #$7
@StartChs:
	PHA
	JSR LoadChannel
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	SSB SOUND_READING_MODE
	STA (zCurTrackAudioPointer), Y
	JSR StartChannel
	PLA
	SEC
	SBC #1
	BPL @StartChs
	JSR MusicOn
	LDA #0
	STA zSFXPriority
	RTS

LoadChannel:
	JSR LoadMusicByte
	LDY #1
	JSR AddAudioOffset
	LDA zCurMusicByte
	AND #$0f
	STA zCurChannel
	JSR LoadMusicByte
	PHA
	LDY #1
	JSR AddAudioOffset
	JSR LoadMusicByte
	PHA
	LDY #1
	JSR AddAudioOffset
	LDA zCurTrackAudioPointer
	STA zMusicHeader
	LDA zCurTrackAudioPointer + 1
	STA zMusicHeader + 1
	JSR UpdateTrackPointer
	LDY #CHANNEL_FLAGS1
	LDA (zCurTrackAudioPointer), Y
	RSB SOUND_CHANNEL_ON
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_STRUCT_LENGTH
	LDA #0
@Loop:
	STA (zCurTrackAudioPointer), Y
	DEY
	BNE @Loop
	LDY #CHANNEL_TEMPO
	STA (zCurTrackAudioPointer), Y
	INY
	CLC
	ADC #1
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_NOTE_LENGTH
	STA (zCurTrackAudioPointer), Y
	LDA #$7f
	LDY #CHANNEL_SWEEP
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_MUSIC_ADDRESS + 1
	PLA
	STA (zCurTrackAudioPointer), Y
	DEY
	PLA
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_MUSIC_ID
	LDA zMusicID
	STA (zCurTrackAudioPointer), Y
	INY
	INY
	LDA zMusicBank
	STA (zCurTrackAudioPointer), Y
	RTS

LoadMusicByte:
	LDA zCurTrackAudioPointer + 1
	AND #$3F
REPT 5
	LSR A
ENDR
	TAX
	LDA zMusicBank
	JSR _LoadMusicByte
	LDA zCurMusicByte
	RTS

.include "src/audio/notes.asm"
.include "src/audio/drumkits-dpcm.asm"
.include "src/audio/drumkits-noise.asm"

UpdateTrackPointer:
	LDA zCurChannel
	ASL A
	TAY
	LDA ChannelPointers, Y
	STA zCurTrackAudioPointer
	INY
	LDA ChannelPointers, Y
	STA zCurTrackAudioPointer + 1
	RTS

ChannelPointers:
; music channels
	.dw iChannel1
	.dw iChannel2
	.dw iChannel3
	.dw iChannel4
	.dw iChannel5
; sfx channels
	.dw iChannel6
	.dw iChannel7
	.dw iChannel8
	.dw iChannel9
	.dw iChannel10

ClearChannels:
	LDY #0
	LDA #$10
	STY rMIX
	STA rNR10
	STY rNR11
	STY rNR12
	STY rNR13
	STA rNR20
	STY rNR21
	STY rNR22
	STY rNR23
	STY rNR30
	STY rNR32
	STY rNR33
	STA rNR40
	STY rNR42
	STY rNR43
	STY rNR50
	STY rNR52
	STY rNR53
	RTS

ApplyEnvLength:
	LDY #CHANNEL_FLAGS2
	LDA (zCurTrackAudioPointer), Y
	RPL
	LDY #CHANNEL_NOTE_FLAGS
	LDA (zCurTrackAudioPointer), Y
	SSB NOTE_DUTY_OVERRIDE
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_ENV_LENGTH
	LDA (zCurTrackAudioPointer), Y
	TAX
	AND #$77
	REQ
	TXA
	BMI @FadeIn
; fadeout
	DEX
	TXA
	STA (zCurTrackAudioPointer), Y
	AND #$07
	RNE
	JSR @ResetTimer
	DEX
	TXA
	AND #$1f
	CMP #$10
	BCS @Apply
	RTS
@FadeIn:
	DEX
	TXA
	STA (zCurTrackAudioPointer), Y
	AND #$07
	RNE
	JSR @ResetTimer
	INX
	TXA
	AND #$1f
	REQ
@Apply:
	STA (zCurTrackAudioPointer), Y
	RTS
@ResetTimer
	LDA (zCurTrackAudioPointer), Y
REPT 4
	LSR A
ENDR
	AND #$07
	ORA (zCurTrackAudioPointer), Y
	STA (zCurTrackAudioPointer), Y
	LDY #CHANNEL_VOLUME_ENVELOPE
	LDA (zCurTrackAudioPointer), Y
	TAX
	RTS:

FetchSFXEquivalent:
	LDA #CHANNEL_STRUCT_LENGTH * NUM_MUSIC_CHANS
	ADC zCurTrackAudioPointer
	STA zCurTrackAudioPointer
	LDA #0
	ADC zCurTrackAudioPointer + 1
	STA zCurTrackAudioPointer + 1
	LDA (zCurTrackAudioPointer), Y
	PHA
	JSR UpdateTrackPointer
	PLA
	RTS
