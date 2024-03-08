.enum $0001
C_:	.dsb 1
C#:	.dsb 1
D_:	.dsb 1
D#:	.dsb 1
E_:	.dsb 1
F_:	.dsb 1
F#:	.dsb 1
G_:	.dsb 1
G#:	.dsb 1
A_:	.dsb 1
A#:	.dsb 1
B_:	.dsb 1
.ende

.enum $0000
CHAN1:		.dsb 1
CHAN2:		.dsb 1
CHAN3:		.dsb 1
CHAN4:		.dsb 1
CHAN5:		.dsb 1
NUM_MUSIC_CHANS:
CHAN6:		.dsb 1
CHAN7:		.dsb 1
CHAN8:		.dsb 1
CHAN9:		.dsb 1
CHAN10::	.dsb 1
NUM_CHANNELS:
NUM_NOISE_CHANS = NUM_CHANNELS - NUM_MUSIC_CHANS
.ende

.enum $0000
CHANNEL_MUSIC_ID:		.dsb 1
CHANNEL_SWEEP:			.dsb 1
CHANNEL_MUSIC_BANK:		.dsb 1
CHANNEL_FLAGS1:			.dsb 1
CHANNEL_FLAGS2:			.dsb 1
CHANNEL_FLAGS3:			.dsb 1
CHANNEL_MUSIC_ADDRESS:		.dsb 2
CHANNEL_LAST_MUSIC_ADDRESS:	.dsb 2
				.dsb 2
CHANNEL_NOTE_FLAGS:		.dsb 1
CHANNEL_CONDITION:		.dsb 1
CHANNEL_DUTY_CYCLE:		.dsb 1
CHANNEL_VOLUME_ENVELOPE:	.dsb 1
CHANNEL_FREQUENCY:		.dsb 2
CHANNEL_PITCH:			.dsb 1
CHANNEL_OCTAVE:			.dsb 1
CHANNEL_TRANSPOSITION:		.dsb 1
CHANNEL_NOTE_DURATION:		.dsb 2
				.dsb 1
CHANNEL_LOOP_COUNT:		.dsb 1
CHANNEL_TEMPO:			.dsb 2
CHANNEL_TRACKS:			.dsb 1
CHANNEL_DUTY_CYCLE_PATTERN:	.dsb 1
CHANNEL_VIBRATO_COUNTER:	.dsb 1
CHANNEL_VIBRATO_PREAMBLE:	.dsb 1
CHANNEL_VIBRATO_DEPTH:		.dsb 1
CHANNEL_VIBRATO_TIMER:		.dsb 1
CHANNEL_PITCH_SLIDE_TARGET:	.dsb 2
CHANNEL_PITCH_SLIDE_AMOUNT:	.dsb 1
CHANNEL_PITCH_SLIDE_FRACTION:	.dsb 1
CHANNEL_PITCH_SLIDE_TEMPO:	.dsb 1
CHANNEL_STACCATO_COUNTER:	.dsb 1
CHANNEL_PITCH_OFFSET:		.dsb 2
CHANNEL_RELATIVE_PITCH:		.dsb 1
CHANNEL_ENV_SEQUENCE:		.dsb 1
CHANNEL_ENV_SEQUENCE_OFFSET:	.dsb 1
CHANNEL_STACCATO:		.dsb 1
CHANNEL_NOTE_LENGTH:		.dsb 1
CHANNEL_ENV_LENGTH:		.dsb 1
CHANNEL_ENV_BACKUP:		.dsb 1
				.dsb 2
CHANNEL_STRUCT_LENGTH:
.ende

.enum $0000
SOUND_CHANNEL_ON:	.dsb 1
SOUND_SUBROUTINE:	.dsb 1
SOUND_LOOPING:		.dsb 1
SOUND_READING_MODE:	.dsb 1
SOUND_NOISE:		.dsb 1
SOUND_CRY:		.dsb 1
SOUND_DPCM:		.dsb 1
.ende

.enum $0000
SOUND_VIBRATO:		.dsb 1
SOUND_PITCH_SLIDE:	.dsb 1
SOUND_DUTY_LOOP:	.dsb 1
SOUND_STACCATO:		.dsb 1
SOUND_PITCH_OFFSET:	.dsb 1
SOUND_ENV_SEQUENCE:	.dsb 1
SOUND_RELATIVE_PITCH:	.dsb 1
SOUND_ENV_TIMER:
.ende

.enum $0000
SOUND_VIBRATO_DIR:	.dsb 1
SOUND_PITCH_SLIDE_DIR:	.dsb 1
SOUND_REL_PITCH_FLAG:	.dsb 1
.ende

.enum $0000
SOUND_INPUT_CH1_F:	.dsb 1
SOUND_INPUT_CH2_F:	.dsb 1
SOUND_INPUT_CH3_F:	.dsb 1
SOUND_INPUT_CH4_F:	.dsb 1
SOUND_INPUT_CH5_F:	.dsb 1
.ende

.enum $0000
NOTE_DUTY_OVERRIDE:	.dsb 1
NOTE_FREQ_OVERRIDE:	.dsb 1
NOTE_ENV_OVERRIDE:	.dsb 1
NOTE_PITCH_SWEEP:	.dsb 1
NOTE_NOISE_SAMPLING:	.dsb 1
NOTE_REST:		.dsb 1
NOTE_VIBRATO_OVERRIDE:	.dsb 1
NOTE_DELTA_SAMPLING:	.dsb 1
.ende

; zLowHealthAlarm
DANGER_PITCH_F = 4
DANGER_ON_F = 7

SOUND_PRIORITY_F = 0
SOUND_EVENT_F = 0
MUSIC_ON_F = 0

LINEAR_MASK = $7F
LINEAR_LOOP = $80

; zMusicSilence
MUSIC_CUT_IN_F = 7

.enum 0
DMC_3_0:
DMC_3_0_END:
DMC_3_1:	.dsb $21
DMC_3_1_END:
	.dsb 3
DMC_3_2:	.dsb $13
DMC_3_2_END:
	.dsb 1
DMC_3_3:	.dsb $1d
DMC_3_3_END:
	.dsb 3
DMC_3_4:	.dsb $22
DMC_3_4_END:
	.dsb 2
DMC_3_11:	.dsb $30
DMC_3_11_END:
DMC_3_12:	.dsb $9c
DMC_3_12_END:
DMC_4_5:	.dsb $23
DMC_4_5_END:
	.dsb 1
DMC_4_8:	.dsb $b
DMC_4_8_END:
	.dsb 1
DMC_4_9:	.dsb $16
DMC_4_9_END:
	.dsb 2
DMC_1_10:	.dsb $23
DMC_1_10_END:
	.dsb 1
DMC_1_11:	.dsb $1b
DMC_1_11_END:
	.dsb 1
DMC_1_12:	.dsb $13
DMC_1_12_END:
	.dsb 1
.ende
.enum $200
DMC_0_5:	.dsb $98
DMC_0_5_END:
.ende
