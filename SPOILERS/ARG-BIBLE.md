# ARG Bible

Every puzzle is fair. Every anonymous message has a speaker. No puzzle requires illegal activity, trespassing, harassment, doxxing, contacting real-world strangers, or dangerous behaviour.

Anti-frustration is mandatory: hint 1 after 3 failed filings, hint 2 after 6, always solvable from in-game material.

---

## Season I — THE ARCHIVE (playable)

### ARG-I-01 — The welcome cipher

- **Puzzle ID:** ARG-I-01
- **Narrative purpose:** Teach the Archive's voice. Prove that identifiers are keys. Open the cabinet.
- **Starting clue:** Inbox message `SOURCE: UNKNOWN / ID: 17-A` body `FGVE KYV TRSZEVK`.
- **Hidden clue:** The ID number is the Caesar shift. 17-A is not flavour text.
- **Required deduction:** Caesar shift +17 (A→R, or equivalently decode by shifting 17).
- **Solution:** `OPEN THE CABINET`
- **Difficulty:** Easy
- **Optional hint 1:** The identifier on the message is not decoration.
- **Optional hint 2:** Shift every letter by seventeen.
- **Consequence:** Unlocks personnel, memo, index, audio, daybook fragment.
- **Connected season:** II (17-A is a shift), IV (first words the Archive ever said to slot 17).
- **Connected character:** Archive (Nora's leftover template).
- **Red herring:** Vigenère with key UNKNOWN or AUTHENTICITY.
- **Anti-frustration:** Decoder accepts the phrase after 3 fails it names "shift cipher"; after 6 it names seventeen.

### ARG-I-02 — Nora's margin

- **Puzzle ID:** ARG-I-02
- **Narrative purpose:** Make Nora specific. Plant VESPER as a place-word before it is a place.
- **Starting clue:** Personnel file VALE, Nora. Six numbered shift notes.
- **Hidden clue:** First letters stand up: V-E-S-P-E-R. UV mode brightens the initials.
- **Required deduction:** Acrostic, top to bottom.
- **Solution:** `VESPER`
- **Difficulty:** Easy
- **Optional hint 1:** She numbered the notes. She also stood them in a line.
- **Optional hint 2:** Read the first letter of each shift note, top to bottom.
- **Consequence:** Unlocks Subject Zero stub.
- **Connected season:** II (the wing), III (the hymn).
- **Connected character:** Nora Vale
- **Red herring:** The dates look like a numeric cipher. They are dates.
- **Anti-frustration:** UV inspect highlights initials. Hint 2 names acrostic.

### ARG-I-03 — Timehold

- **Puzzle ID:** ARG-I-03
- **Narrative purpose:** Environmental clue. The clock is an address, not broken UI.
- **Starting clue:** Header clock frozen at 03:17. Tooltip: TIMEHOLD 03:17 — CLOCK UNSYNCED.
- **Hidden clue:** 03:17 names Room 317 in Vesper Wing.
- **Required deduction:** File the time (0317 / 03:17 / 317) in the decoder, or tap the clock.
- **Solution:** `0317` (accepted variants: 03:17, 317, VW-317)
- **Difficulty:** Medium
- **Optional hint 1:** The facility clock has not moved since you arrived.
- **Optional hint 2:** Search the cabinet for the time, or for the room it names.
- **Consequence:** Unlocks VW-317 schematic fragment.
- **Connected season:** II (Elias's office; badge swipe 03:17:17 after disappearance).
- **Connected character:** Elias Kade
- **Red herring:** Using 17 as another Caesar key, or 0317 as a locker combo elsewhere.
- **Anti-frustration:** Tapping the clock submits 0317. Tooltip states TIMEHOLD.

### ARG-I-04 — Spectrum 440

- **Puzzle ID:** ARG-I-04
- **Narrative purpose:** Audio is visual. Plant ZERO and 440.17 for III.
- **Starting clue:** `hum_440.rec` in Audio lab. A tone plus spectrogram renderer.
- **Hidden clue:** The bright band is handwriting spelling ZERO. 17 Hz amplitude modulation on 440 Hz.
- **Required deduction:** Read the spectrogram, not the pitch.
- **Solution:** `ZERO` (also `SUBJECT ZERO`)
- **Difficulty:** Medium
- **Optional hint 1:** Listen with your eyes. The lab can render frequency as shape.
- **Optional hint 2:** The bright band is not noise. It is handwriting.
- **Consequence:** Unlocks corridor recording.
- **Connected season:** III (440.17 as door), IV (the reader).
- **Connected character:** Subject Zero
- **Red herring:** 440 as Caesar shift or numeric code.
- **Anti-frustration:** Spectrogram is visible without playing audio. Play is flavour.

### ARG-I-05 — The interpolated sentence

- **Puzzle ID:** ARG-I-05
- **Narrative purpose:** Teach that genuine documents can be manipulated. Introduce Observer.
- **Starting clue:** DIR-11 transfer memo claiming Nora transferred. Stamp CHECKSUM FAIL.
- **Hidden clue:** Two checksums. CHK-B mismatch on the addendum `THE OBSERVER HAS FILED YOU.`
- **Required deduction:** The sentence that does not belong names the speaker.
- **Solution:** `OBSERVER`
- **Difficulty:** Medium
- **Optional hint 1:** A real Halcyon memo never carries a second checksum.
- **Optional hint 2:** The sentence that does not belong names the one who filed you.
- **Consequence:** Unlocks OBS-1 message, which uses the player's filed name.
- **Connected season:** II (Observer reports), IV (fabricated sources).
- **Connected character:** Observer
- **Red herring:** HALCYON letterhead as passphrase.
- **Anti-frustration:** UV line states HALCYON is a letterhead.

### ARG-I-06 — Uneven bars

- **Puzzle ID:** ARG-I-06
- **Narrative purpose:** Subject Zero is alive inside the record. Morse as redaction.
- **Starting clue:** SUBJECT ZERO stub. Classification bars of uneven width. Footer: "width is signal".
- **Hidden clue:** Short = dot, long = dash, larger gaps = letters. Encodes STILL HERE.
- **Required deduction:** Morse from bar widths.
- **Solution:** `STILL HERE`
- **Difficulty:** Hard
- **Optional hint 1:** Classification bars are not a texture. Width is signal.
- **Optional hint 2:** Short bar is a dot. Long bar is a dash. Gaps break letters. Morse.
- **Consequence:** Plants Season IV's proof-of-life line.
- **Connected season:** IV (Zero to the reader), III (reversed channel says the same).
- **Connected character:** Subject Zero
- **Red herring:** Counting bars as decimal, or treating them as a barcode.
- **Anti-frustration:** Footer already says width is signal. Hint 2 names Morse.

### ARG-I-07 — The index that lies

- **Puzzle ID:** ARG-I-07
- **Narrative purpose:** Community-discussable wound. Plant Season III by absence.
- **Starting clue:** Index of live records claims twelve, presents a hole at 07: FILE MOVED TO LISTENING / key: 440.
- **Hidden clue:** 07 is not deleted. Destination is a season name.
- **Required deduction:** The missing file is the next neighbourhood.
- **Solution:** `LISTENING` (also 440, 440.17, 07, FILE 07)
- **Difficulty:** Medium
- **Optional hint 1:** Twelve records are listed. Count them on your fingers.
- **Optional hint 2:** The missing number was moved, not deleted. The destination is a season name.
- **Consequence:** Files the edge I→III. Does not open Season III gameplay yet.
- **Connected season:** III
- **Connected character:** Archive
- **Red herring:** Record 12 (last) looks like the secret. The wound is in the middle.
- **Anti-frustration:** The hole is labelled in plain text; the puzzle is noticing and filing it.

### ARG-I-08 — Vault 17 (Season I finale)

- **Puzzle ID:** ARG-I-08
- **Narrative purpose:** Combine the graph. Close the season. Open sealed dossiers II–IV. Cliffhanger.
- **Starting clue:** Vault tab restricted. Decoder copy: "Wing. Shift. Subject."
- **Hidden clue:** Order is how the Archive files itself: place, instance, name.
- **Required deduction:** Concatenate VESPER + 17 + ZERO.
- **Solution:** `VESPER-17-ZERO`
- **Difficulty:** Hard
- **Optional hint 1:** Three words you have already earned. Wing. Shift. Subject.
- **Optional hint 2:** Join them in the order the Archive files itself: place, instance, name.
- **Consequence:** Unlocks vault letter, second copy of 17-A (Future Player), sealed dossiers II–IV. Season I complete.
- **Connected season:** IV (the passphrase is the identity formula).
- **Connected character:** Future Player
- **Red herring:** HALCYON-NORA-ELIAS.
- **Anti-frustration:** After 6 fails, names the three solved words in order.

**Season I cliffhanger:** Nora's last badge swipe is timestamped after she was filed missing.

---

## Season II — THE WITNESS (designed; sealed dossier in client)

### ARG-II-01 — Badge log

- **Puzzle ID:** ARG-II-01
- **Narrative purpose:** Prove Nora acted after death-on-paper. Reinterpret I's daybook.
- **Starting clue:** Vesper Wing badge CSV in the sealed dossier (in-game table, not a real file server).
- **Hidden clue:** One row is out of chronological order: VALE 03:17:17 the day after DISAPPEARANCE FILED.
- **Required deduction:** Sort by time, don't trust the printed order.
- **Solution:** `AFTER` or `NORA SWIPED AFTER` (design accept: `AFTER`)
- **Difficulty:** Medium
- **Optional hint 1:** Printed order is the lie. Time order is the document.
- **Optional hint 2:** Find the swipe that happens after the disappearance row.
- **Consequence:** Unlocks Room 317 interior.
- **Connected season:** I (daybook "I will swipe after they file me missing"), IV (Nora is not dead).
- **Connected character:** Nora Vale
- **Red herring:** A second "error" row planted for Elias at 04:04.
- **Anti-frustration:** A "sort by time" control exists on the table.

### ARG-II-02 — Whiteboard graph

- **Puzzle ID:** ARG-II-02
- **Narrative purpose:** Show the player the graph thesis in-world, as Elias's work.
- **Starting clue:** Photo-plate of Elias's whiteboard in 317. Four nodes labelled I–IV, centre node blank.
- **Hidden clue:** The blank node is labelled, in UV, with the player's filed name.
- **Required deduction:** The centre of the graph is the reader.
- **Solution:** The player's filed name (dynamic) or `READER`
- **Difficulty:** Medium
- **Optional hint 1:** Four neighbourhoods. Something sits in the middle.
- **Optional hint 2:** Ultraviolet. The blank is not blank.
- **Consequence:** Unlocks Observer report OBS-2.
- **Connected season:** I (player name), IV (you were the centre).
- **Connected character:** Elias Kade
- **Red herring:** Labelling the centre ARCHIVE. Close, but Elias wrote a person.
- **Anti-frustration:** UV toggle already taught in I.

### ARG-II-03 — Room 317 inventory

- **Puzzle ID:** ARG-II-03
- **Narrative purpose:** Environmental reconstruction. Tuner, mug, face-down photograph, door LISTEN.
- **Starting clue:** Schematic from I is now an explorable room (hotspots).
- **Hidden clue:** Tuner readout 440.17. Photograph reverse: "don't trust the index".
- **Required deduction:** File the frequency, or LISTEN, matching I's audio and I's hole.
- **Solution:** `440.17`
- **Difficulty:** Easy
- **Optional hint 1:** The sill has a machine that was never turned off.
- **Optional hint 2:** It is already showing the number.
- **Consequence:** Plants III's door.
- **Connected season:** I (hum_440), III (listening door).
- **Connected character:** Elias Kade
- **Red herring:** The mug inscription looks like a cipher; it is a tea stain pattern.
- **Anti-frustration:** Readout is literal.

### ARG-II-04 — Observer report

- **Puzzle ID:** ARG-II-04
- **Narrative purpose:** The watchdog uses the login. Observation is personal.
- **Starting clue:** OBS-2: "SUBJECT [playerName] walks rooms that are not rooms."
- **Hidden clue:** The report ID hashes to OBSERVER using the same 17-shift as 17-A on the word "WATCH".
- **Required deduction:** Notice the name is yours; file OBSERVER again, or WATCH.
- **Solution:** `WATCH` (alt `OBSERVER`)
- **Difficulty:** Medium
- **Optional hint 1:** The report already knows your daybook name.
- **Optional hint 2:** Shift WATCH by seventeen. You have done this before.
- **Consequence:** Observer flicker increases. One fabricated inbox item appears.
- **Connected season:** I (OBS-1), IV (fabricated source).
- **Connected character:** Observer
- **Red herring:** A second report signed ELIAS. Forged.
- **Anti-frustration:** If the player never set a name, UNINDEXED is used consistently.

### ARG-II-05 — Season II finale (the palace)

- **Puzzle ID:** ARG-II-05
- **Narrative purpose:** Reinterpret the building. Vesper Wing is Nora's memory palace.
- **Starting clue:** Walking the four rooms in the order of Nora's acrostic (V-E-S-P then E-R as exit).
- **Hidden clue:** Room initials spell VESPER again. The last door is labelled with the player's name.
- **Required deduction:** The map is a mind, not architecture.
- **Solution:** `PALACE` or `NORA`
- **Difficulty:** Hard
- **Optional hint 1:** You have already walked this word, as letters, in her file.
- **Optional hint 2:** The wing is not a building.
- **Consequence:** Season II cliffhanger. Sealed III opens a crack: a frequency.
- **Connected season:** I (acrostic), III (hymn maps the palace), IV (palace is the loop).
- **Connected character:** Nora Vale
- **Red herring:** A fire-escape map of a real-looking coastal lab. Fictional. Not a real site. Not visitable.
- **Anti-frustration:** Walking order can be shown as a dotted line after 6 failed filings.

**Season II cliffhanger:** Room 317 is a memory palace. You have been walking through Nora.

---

## Season III — THE OBSERVER (designed)

### ARG-III-01 — Beat frequency

- **Puzzle ID:** ARG-III-01
- **Narrative purpose:** 440.17 is a door. Audio as number.
- **Starting clue:** Two tones, 440 and 457.17, labelled poorly as "calibration".
- **Hidden clue:** Beat frequency |457.17−440| = 17.17, pointing at 17-A and 03:17.
- **Required deduction:** Subtract the tones.
- **Solution:** `17.17` or `17`
- **Difficulty:** Medium
- **Optional hint 1:** Two close tones produce a pulse you can count.
- **Optional hint 2:** Subtract.
- **Consequence:** Opens Subject Zero interview.
- **Connected season:** I (17-A, 03:17), II (tuner).
- **Connected character:** Archive
- **Red herring:** Adding the tones (897.17).
- **Anti-frustration:** A "difference" readout can be enabled in the audio lab.

### ARG-III-02 — Reversed channel

- **Puzzle ID:** ARG-III-02
- **Narrative purpose:** Zero speaks. Same sentence as the Morse bars.
- **Starting clue:** Interview tape, left channel forward, right channel reversed.
- **Hidden clue:** Right channel reversed is STILL HERE.
- **Required deduction:** Flip one channel. Match to ARG-I-06.
- **Solution:** `STILL HERE`
- **Difficulty:** Medium
- **Optional hint 1:** Headphones are a suggestion. One ear is wrong.
- **Optional hint 2:** Reverse the right channel. You have read this sentence as bars.
- **Consequence:** Confirms I-06 was Zero, not a random code.
- **Connected season:** I (Morse), IV (Zero→player).
- **Connected character:** Subject Zero
- **Red herring:** The left channel's explicit lie: "I am Elias."
- **Anti-frustration:** A Reverse Channel button exists in the lab. No outside audio tools required.

### ARG-III-03 — Community book cipher

- **Puzzle ID:** ARG-III-03
- **Narrative purpose:** Community-solvable, entirely in-corpus. No outside websites required.
- **Starting clue:** A string of triples `2.1.1 / 1.6.1 / 4.1.4` etc. labelled "index address".
- **Hidden clue:** Document-line-word using only in-game documents (Nora file, memo, index, vault letter).
- **Required deduction:** Book cipher against the official corpus.
- **Solution:** Design phrase: `THE RECORD WRITES BACK`
- **Difficulty:** Community
- **Optional hint 1:** Addresses look like page.line.word. They are document.line.word.
- **Optional hint 2:** Use only files already in the cabinet. Document 1 is Nora.
- **Consequence:** Unlocks the hymn.
- **Connected season:** I (the documents), II (palace text), IV (the thesis of Zero).
- **Connected character:** Future Player (chose a cipher a community can share).
- **Red herring:** Using Wikipedia or any real book. Wrong, and against safety rules.
- **Anti-frustration:** In-game "corpus picker" highlights legal documents. No real-world lookup.

### ARG-III-04 — Hymn Vesper

- **Puzzle ID:** ARG-III-04
- **Narrative purpose:** Audio log titles acrostic the season codes.
- **Starting clue:** Two title lists in the audio lab.
  - List A: Ingress note, Nora's rooms, Graph of four, Record of a clock, Elias at the tuner, Subject still here, Sealed corridor.
  - List B: Vellum hours, Each empty tray, South window, Palace walk, Exit light, Return hymn.
- **Hidden clue:** List A first letters INGRESS. List B first letters VESPER. The missing third list is the season the player is in.
- **Required deduction:** Acrostic the titles, not the lyrics.
- **Solution:** `INGRESS VESPER` or `LISTENING` as the missing third list the player must name.
- **Difficulty:** Medium
- **Optional hint 1:** Do not listen first. Read the titles as a spine.
- **Optional hint 2:** You have done an acrostic in Nora's notes.
- **Consequence:** Reveals the missing third hymn must be named by the player: LISTENING.
- **Connected season:** I, II, IV (Recursion hymn sealed).
- **Connected character:** Nora Vale
- **Red herring:** Musical notes as letters (A–G only). Incomplete on purpose.
- **Anti-frustration:** Titles remain on screen while audio plays.

### ARG-III-05 — Season III finale

- **Puzzle ID:** ARG-III-05
- **Narrative purpose:** The Archive is playback, not storage. Zero writes back.
- **Starting clue:** Protocol diagram: STORE → PLAY → STORE. One arrow is reversed at Subject Zero.
- **Hidden clue:** Zero's box is the only one with an outbound arrow labelled WRITE.
- **Required deduction:** File `PLAYBACK` or `WRITES BACK`.
- **Solution:** `WRITES BACK`
- **Difficulty:** Hard
- **Optional hint 1:** Storage would not need a microphone.
- **Optional hint 2:** Only one record has an outbound arrow.
- **Consequence:** Season III cliffhanger. File 07 still unnamed. That name is Season IV.
- **Connected season:** I (Zero stub), II (palace as playback of Nora), IV (player is the record).
- **Connected character:** Subject Zero
- **Red herring:** A "delete" arrow on Nora. She was not deleted; she was extracted.
- **Anti-frustration:** Diagram highlights the outbound arrow after 6 fails.

**Season III cliffhanger:** Subject Zero is the only record that writes back. File 07 is still a hole with your outline.

---

## Season IV — THE LAST RECORD (designed; reinterprets)

### ARG-IV-01 — Speaker table

- **Puzzle ID:** ARG-IV-01
- **Narrative purpose:** Every SOURCE: UNKNOWN had a speaker. Fair fingerprints were always present.
- **Starting clue:** A blank table of message IDs. Fingerprint guide: punctuation, favourite nouns, files-you vs warns-you.
- **Hidden clue:**
  - 17-A first copy: headers + leftover template → Archive
  - 17-B daybook: mug, badge, checksum is a person → Nora
  - OBS-1 / OBS-2: SUBJECT, filing → Observer
  - 17-A second copy: "file that remembers you", your punctuation → Future Player
  - DIR-11 addendum: interpolated → Fabricated (Observer)
  - Morse / reversed: STILL HERE → Subject Zero
  - Elias never sends anonymous; he signs, or he writes on boards
- **Required deduction:** Fill the table. One row is a forgery.
- **Solution:** Table accepted when Archive, Nora, Observer, Future, Fabricated, Zero are correctly placed.
- **Difficulty:** Hard
- **Optional hint 1:** Who files you, who warns you, who sounds like your own typing.
- **Optional hint 2:** Elias signs his work. He is not in the anonymous tray.
- **Consequence:** Unlocks identity formula.
- **Connected season:** I, II, III (all messages).
- **Connected character:** All
- **Red herring:** Assigning 17-A first copy to Nora because it uses her template. Template ≠ sender.
- **Anti-frustration:** Fingerprint guide is an in-game document. Drag-and-drop names. No timer.

### ARG-IV-02 — Slot 17 instance A

- **Puzzle ID:** ARG-IV-02
- **Narrative purpose:** Reinterpret 17-A. Not a shift. A slot.
- **Starting clue:** Protocol index: records stored as `SLOT-INSTANCE`. Examples: 04-C, 12-B, 17-A.
- **Hidden clue:** 17-A is empty in the printed index and present in the player's header the entire game.
- **Required deduction:** You are instance A of slot 17.
- **Solution:** `I AM 17-A` or `SLOT 17`
- **Difficulty:** Medium
- **Optional hint 1:** The node name in the header never changed.
- **Optional hint 2:** A is not a letter in a shift code. A is an instance.
- **Consequence:** Vault passphrase reinterprets as identity.
- **Connected season:** I (the first header), II (node), III (17 Hz).
- **Connected character:** Future Player / Subject Zero (same loop)
- **Red herring:** Instance B exists as a decoy "better player". Empty on purpose.
- **Anti-frustration:** Highlight NODE 17-A in the header when this puzzle is active.

### ARG-IV-03 — File 07

- **Puzzle ID:** ARG-IV-03
- **Narrative purpose:** The index hole was the original name. Withheld, not lost.
- **Starting clue:** Listening destination of file 07 is a folder titled with the player's filed name.
- **Hidden clue:** If the player chose UNINDEXED, file 07 is named UNINDEXED. The hole was always their cover story.
- **Required deduction:** File 07 is the name they typed in the daybook.
- **Solution:** The player's filed name
- **Difficulty:** Medium
- **Optional hint 1:** The hole is shaped like a login.
- **Optional hint 2:** Open the daybook.
- **Consequence:** Subject Zero's withheld identity is the cover name — or the real one if they typed it.
- **Connected season:** I (ident screen), III (the hole).
- **Connected character:** Subject Zero
- **Red herring:** File 07 = NORA. Close in spirit, wrong in filing.
- **Anti-frustration:** If they forgot, the ident screen can be reopened read-only.

### ARG-IV-04 — Season IV finale (remain or extract)

- **Puzzle ID:** ARG-IV-04
- **Narrative purpose:** Resolve without a new cipher. Choice as interpretation.
- **Starting clue:** Nora's extraction protocol vs Observer's remain-as-watchdog protocol. Both already described in I–III if you were reading edges.
- **Hidden clue:** Remain rewrites boot text to "Welcome back, Zero." Extract rewrites it to Nora's last margin: "If you are reading the cabinet, I am not in it."
- **Required deduction:** Choose. Both are canon branches, not moral quizzes.
- **Solution:** `REMAIN` or `EXTRACT`
- **Difficulty:** Easy (as a puzzle), hard (as a reading)
- **Optional hint 1:** This is not a cipher. It is a filing decision.
- **Optional hint 2:** Both endings are true for someone.
- **Consequence:** Replay seed. Third loop can send a message that appears in Season I as 17-A.
- **Connected season:** I (boot), II (palace), III (write-back), all.
- **Connected character:** Nora (extract) / Observer (remain) / Future Player (the choice itself)
- **Red herring:** A third button labelled DELETE. It fails checksum and is the Observer's trap.
- **Anti-frustration:** No missable ending. Choice can be replayed from Vault.

**Season IV ending reveal:** The file that remembers you is the file you are reading. The first anonymous message was you, later, using the Archive's mouth.
