# gctools

gctools is a set of tools for reading and translating video game files. These tools can understand:
- AFS archives from various Sega games (afsdump)
- GCM and TGC GameCube disc images (gcmdump)
- GSL files from Phantasy Star Online (gsldump)
- GVM files from Phantasy Star Online (gvmdump)
- RCF files from The Simpsons: Hit and Run (rcfdump)
- PAE files from Phantasy Star Online Episode III (pae2gvm)
- PRS files from Phantasy Star Online (prs)
- Yay0 and Yaz0 files from various Nintendo games (prs)
- AAF, BX, and AW files from Super Mario Sunshine, Luigi's Mansion, Pikmin, and other games (smsdumpbanks, smssynth)

## Building

- Build and install phosg (https://github.com/fuzziqersoftware/phosg).
- Install OpenAL if you don't have it already.
- Install libsamplerate (http://www.mega-nerd.com/SRC/).
- Run `make` in the root directory of gctools. Executables will be generated for each tool. These tools all build and run on Mac OS X, but are untested on other platforms.

## The tools

**afsdump** - extracts all files in an AFS archive to the current directory. Works with AFS archives found in several Sega games.
- Example: `mkdir out && cd out && afsdump ../archive.afs`

**gcmdump** - extracts all files in a GCM file (GameCube disc image) or TGC file (embedded GameCube disc image) to the current directory. You can force formats with the --gcm or --tgc options (by default gcmdump will try to figure out the file format itself).
- Example: `mkdir out && cd out && gcmdump ../image.gcm`

**gsldump** - extracts all files in a GSL archive to the current directory. This format was used in multiple versions of Phantasy Star Online for various game parameters.
- Example: `mkdir out && cd out && gsldump ../archive.gsl`

**gvmdump** - extracts all files in a GVM archive to the current directory. Note: not thoroughly tested; may fail for some archives.
- Example: `mkdir out && cd out && gvmdump ../archive.gvm`

**rcfdump** - extracts all files in a RCF archive to the current directory.
- Example: `mkdir out && cd out && rcfdump ../archive.rcf`

**pae2gvm** - extracts the embedded GVM from a PAE file. The decompressed PAE data is saved as <filename>.dec; the output GVM is saved as <filename>.gvm.
- Example: `pae2gvm file.pae`

**prs/prs** - decompresses data in PRS, Yay0, and Yaz0 formats, or compresses data in PRS format.
- Example (decompress PRS): `prs -d < file.prs > file.bin`
- Example (compress PRS): `prs < file.bin > file.prs`
- Example (decompress Yay0): `prs --yay0 -d < file.yay0 > file.bin`
- Example (decompress Yaz0): `prs --yaz0 -d < file.yaz0 > file.bin`

**sms/smsdumpbanks** - extracts the contents of instrument and waveform banks in AAF or BX format. Games using this format include Luigi's Mansion, Pikmin, and Super Mario Sunshine. Produces text files describing the instruments, uncompressed .wav files containing the sounds, and .bms files containing the music sequences. Before running this program, do the steps in the "Getting auxiliary files" section below.
- Example: `mkdir sms_decoded_data && smsdumpbanks sms_extracted_data/AudioRes sms_decoded_data`

**sms/smssynth** - deals with BMS music sequence programs. It can disassemble them, convert them into .wav files, or play them in realtime. It doesn't implement everything that Nintendo's engine implements, so sometimes things don't work and the output sounds a bit different from the actual in-game music.
- For Super Mario Sunshine, some sequences sound almost perfect; a few are noticeably broken and sound terrible. Note that the game uses track 15 for Yoshi's drums, which you'll have to manually disable if you don't want them.
- For Pikmin, all sequences sound different from how they sound in-game (and worse) but are easily recognizable.
- For Luigi's Mansion, most sequences don't play at all.

For sequences that loop, this program will run forever unless you cancel it or give a time limit. Before running this program, do the steps in the "Getting auxiliary files" section below.
- Example (convert to 4-minute WAV, no Yoshi drums): `smssynth --disable-track=15 --audiores-directory=sms_extracted_data/AudioRes --sample-rate=48000 k_bianco.com --output-filename=k_bianco.com.wav --time-limit=240`
- Example (play in realtime, with Yoshi drums): `smssynth --audiores-directory=sms_extracted_data/AudioRes --sample-rate=48000 k_bianco.com --linear --play`
- Example (Pikmin, play in realtime): `smssynth --audiores-directory=pikmin_extracted_data/dataDir/SndData --sample-rate=48000 --linear --play tutorial.jam`

smssynth also can disassemble and play a subset of MIDI files. This was implemented to synthesize the Classic Mac OS version of SimCity 2000's music using the original instruments, which wouldn't play on any MIDI player I tried. To use this functionality, you have to manually specify the instruments, and optionally their base notes (or unity keys). For example:
- `smssynth --midi --midi-channel-instrument=7:simcity.out/snd_10008.wav --midi-channel-instrument=10:simcity.out/snd_10011.wav:0x48 --sample-rate=48000 --play-buffers=64 --linear --play simcity.out/MIDI_10014.midi`

### Getting auxiliary files for Pikmin and Super Mario Sunshine

#### Getting msound.aaf from Super Mario Sunshine

You'll have to copy msound.aaf into the AudioRes directory manually to use the Super Mario Sunshine tools. To do so:
- Get nintendo.szs from the disc image (use gcmdump or some other tool).
- Yaz0-decompress it (you can do this with `prs -d --yaz0 < nintendo.szs > nintendo.szs.rarc`).
- Extract the contents of the archive (you can do this with rarcdump).
- Copy msound.aaf into the AudioRes directory.

#### Getting sequence.barc from Pikmin

You'll have to manually extract the BARC data from default.dol (it's embedded somewhere in there). Open up default.dol in a hex editor and search for the ASCII string "BARC----". Starting at the location where you found "BARC----", copy at least 0x400 bytes out of default.dol and save it as sequence.barc in the SndData/Seqs/ directory. Now you should be able to run smsdumpbanks and smssynth using the Pikmin sound data. `--audiores-directory` should point to the SndData directory from the Pikmin disc (with sequence.barc manually added).
