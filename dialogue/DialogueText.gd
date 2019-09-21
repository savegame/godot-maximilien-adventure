"""
Manage all sentences of a dialogue.
Use SENTENCE_BREAKPOINT to split the text in multiples sentences
e.g.
	1.[b]Hello[/b], this is the first sentence. @
	2.Followed by a second one, much longer than the first one that's cool. @
	3.[color=#ff4136][b]This one is in color with a bold style[/b][/color]. @
	4.[color=#0074d9]This is the last one[/color][b][color=#0074d9][/color][color=#1e92f7]right there[/color][/b]. @
	
Will be split in 4 sentences.
Each sentence will be display with a little animation and will wait for the player to press the talk 
input to display the next sentence.
When all sentence are displayed, the dialogue change to finished
"""
extends RichTextLabel
class_name DialogueText

# emit when all sentences has been displayed
signal dialogue_text_completed

const SENTENCE_BREAKPOINT := '@'
var sentences: Array = []
var current_sentence: String = ''


func _ready() -> void:
	$Timer.connect('timeout', self, '_on_Animated_line')
	visible_characters = 0


"""
Connected to Timer, will display each character of the sentence with a little animation.
manage when the dialogue is completed or 
need to wait for the player to display the next sentence
"""
func _on_Animated_line() -> void:
	if not visible_characters == text.length():
		visible_characters += 1
	elif sentences.empty():
		emit_signal('dialogue_text_completed')
		DialogueManager.dialogue_audio_stop()
	else:
		DialogueManager.dialogue_audio_stop()


"""
Start the dialogue text
"""
func _on_Start() -> void:
	$Timer.start()
	DialogueManager.dialogue_audio_start()


"""
If there is a next sentence, display it or emit dialogue_text_completed signal
"""
func _on_Next_sentence() -> void:
	# currently animating a sentence but player click on talk
	if not visible_characters == text.length():
		DialogueManager.dialogue_audio_stop()
		visible_characters = text.length()
		$Timer.stop()
		if sentences.empty():
			emit_signal('dialogue_text_completed')
	elif not sentences.empty():
		visible_characters = 0
		current_sentence = sentences.pop_front()
		parse_bbcode(current_sentence)
		_on_Start()
	else:
		emit_signal('dialogue_text_completed')


func init(bbcode: String) -> void:
	sentences = split_bb_code(bbcode)


"""
Read bbcode text and split it based on SENTENCE_BREAKPOINT value.
Will clean the splitted string and add it to an array.
@param {String} bbcode
@param {Array} Array - all splitted sentences
"""
func split_bb_code(bbcode: String) -> Array:
	var sentence_raw := bbcode
	var splitted_sentences: Array = []
	var line_search := bbcode.find('%s' % SENTENCE_BREAKPOINT, 0)

	if line_search != -1 and bbcode.length() > line_search:
		while line_search != -1:
			# remove sentence breakpoint
			sentence_raw.erase(line_search, 1)
			
			# clean sentence
			var extrated_sentence := sentence_raw.substr(0, line_search)
			extrated_sentence = extrated_sentence.replace('\n', '')
			extrated_sentence = extrated_sentence.trim_prefix(' ')
			extrated_sentence = extrated_sentence.trim_suffix(' ')
			
			# add current sentence
			splitted_sentences.append(extrated_sentence)
			
			# remove previously added sentence
			sentence_raw = sentence_raw.substr(line_search, sentence_raw.length())
			
			# find the sentence breakpoint
			line_search = sentence_raw.find('%s' % SENTENCE_BREAKPOINT, 0)
	else:
		splitted_sentences.append(sentence_raw)
	return splitted_sentences