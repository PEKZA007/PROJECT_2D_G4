extends RefCounted
class_name StoryData

# ------------------------------------------------------------
#  บทพูดของแต่ละตอน (chapter) ใช้โดย VisualNovel.tscn
#  พูดสลับกันแค่ 2 ตัวละครต่อตอน (อีกฝั่งคือ "เรา" = Player เสมอ)
# ------------------------------------------------------------

const P := "res://assets/characters/"

const CHAPTERS := {
	# --- Day 0: ปฐมบทของร้าน — ทำไมเราถึงมารับช่วงต่อร้านเจลาโต้ ---
	"day0": [
		{"speaker": "", "portrait": "", "text": "มีร้านเจลาโต้ร้านหนึ่งเปิดมายาวนานภายในเมืองแห่งนี้ เป็นร้านที่อร่อยและเป็นที่รักของทุกคน และเราก็กินเจลาโต้ร้านนี้ตั้งแต่เล็กจนโต จนกระทั่งวันหนึ่ง..."},
		{"speaker": "", "portrait": "", "text": "เราได้รับข่าวร้ายว่าคุณลุงเจ้าของร้านทำงานจนมีอาการปวดหลังหนัก จนไม่สามารถเปิดร้านเจลาโต้ของครอบครัวต่อได้ อาจถึงขั้นต้องปิดร้านเพราะไม่มีใครมารับช่วงต่อ!!"},
		{"speaker": "", "portrait": "", "text": "เราที่อยู่ในช่วงว่างงานพอดีจึงตัดสินใจรับช่วงต่อร้านเจลาโต้ \"Good GoodsS gellato house\" เพื่อไม่ให้ร้านที่มีความทรงจำมากมายต้องหายไป"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ไม่คิดเลยว่าหลานจะเสนอตัวมารับช่วงต่อร้านนี้"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "แน่นอนค่ะ หนูตั้งใจว่าจะมารับช่วงต่อเอง คุณลุงไม่ต้องห่วงนะคะ!!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) ใครจะไปยอมปล่อยให้ธุรกิจครอบครัวต้องปิดไปกันล่ะ อย่างน้อยตอนนี้ก็ทำให้เรามีงาน แถมยังได้กินเจลาโต้ทุกวันอีกด้วย"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ลุงยังจำได้เลยตอนหลานเด็กๆ ยังเกาะตู้เย็นร้องไห้ขอให้ลุงตักเจลาโต้ให้กิน ทั้งที่เป็นหวัดน้ำมูกไหลอยู่แท้ๆ ฮะฮะ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "เดี๋ยวๆ หยุดพูดเลยนะคะ ตอนนั้นมันยังเด็ก"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ไม่พูดก็ได้ ฮาฮา เด็กสมัยนี้โตเร็วจริงๆ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เอาล่ะ ค่อยมานั่งรำลึกอดีตวันหลัง ตอนนี้ใกล้เวลาเปิดร้านแล้ว ลุงสอนงานหลานเองนะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ทำอย่างงี้นะหลาน ดูให้ดีๆ"},
	],

	# --- Day 1: วันเปิดร้านวันแรก + ลูกค้าประจำคนแรก "ส้มส้ม" ---
	"day1": [
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เป็นไงบ้างวันเปิดร้านวันแรก"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ยังไหวค่ะ แค่นี้จิ๊บๆ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) เหนื่อยเยอะกว่าที่คิดไว้มากเลย ใครบอกเปิดธุรกิจส่วนตัวแล้วง่าย นี่หลอกกันชัดๆ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ดีดี เด็กสมัยนี้ขยันจริงๆ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เอาล่ะ ถ้าขายแค่เจลาโต้เฉยๆ ร้านก็คงน่าเบื่อ ลุงเอาท็อปปิ้งมาให้แล้ว ทีนี้ลูกค้าก็จะได้กินอะไรหลายๆ แบบ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "วันนี้ขายแค่สามรสไปก่อนนะ พรุ่งนี้ก่อนเปิดร้านเดี๋ยวลุงเพิ่มรสชาติอื่นๆ ให้"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ขอบคุณค่ะ"},
		{"speaker": "", "portrait": "", "text": "*กริ่ง*"},
		{"speaker": "???", "portrait": "", "text": "โอ้ ไม่คิดเลยนะว่าร้านนี้จะกลับมาเปิด... ดีใจจังเลย!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ยินดีต้อนรับค่ะ"},
		{"speaker": "แบม", "portrait": "CustomerE.png", "text": "คนหน้าไม่คุ้นนี่ เธอเป็นพนักงานใหม่หรอ ฉันแบมนะ อยู่แถวนี้"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ก็ทำนองนั้นค่ะ ฉันมารับช่วงต่อร้านนี้แทนคุณลุงน่ะ"},
		{"speaker": "แบม", "portrait": "CustomerE.png", "text": "งั้นหรอ สุดยอดเลยนะ! คุณเจ้าของร้านคนเก่าฉันจำได้ว่ามากินร้านนี้ตั้งแต่เด็กๆ เลย"},
		{"speaker": "แบม", "portrait": "CustomerE.png", "text": "แต่มีช่วงหนึ่งที่ร้านปิดไป ทำเอาเสียใจเลยล่ะ หาร้านแบบนี้ยากมาก จนนึกว่าจะอดกินพิสตาชิโอของร้านนี้แล้ว"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ไม่ต้องห่วงนะคะ ตอนนี้ร้านเรากลับมาเปิดแล้ว"},
		{"speaker": "แบม", "portrait": "CustomerE.png", "text": "นั่นสิ! งั้นฉันขอพิสตาชิโอถ้วยเล็กนะ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้แล้วค่ะ ขอบคุณที่อุดหนุนนะคะ"},
		{"speaker": "แบม", "portrait": "CustomerE.png", "text": "ขอบคุณจ้า ไว้จะแวะมาใหม่นะ"},
	],

	# --- Day 2: เริ่มปรับตัวได้ ลุงไปหาหมอ เจลาโต้ครบทุกรสแล้ว ---
	"day2": [
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "วันนี้วันที่สองแล้วสินะ เริ่มจะปรับตัวได้แล้วแฮะ ค่อยยังชั่วหน่อย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ดูเหมือนคุณลุงจะไปหาหมอเลยไม่อยู่ แต่ก่อนไปก็บอกว่าเพิ่มเจลาโต้อีกสามรสมาให้แล้ว"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "เอาล่ะ ได้เวลาเปิดร้านแล้ว หวังว่าวันนี้จะผ่านไปด้วยดีนะ"},
	],

	# --- Day 3: ลูกค้าตัวน้อยผู้เก็บเงินมาทั้งอาทิตย์ ---
	"day3": [
		{"speaker": "", "portrait": "", "text": "*กริ่ง*"},
		{"speaker": "???", "portrait": "CustomerC.png", "text": "พี่สาวครับ พี่สาวครับ พี่สาวคนสวย ผมชื่อเป๊กนะ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) นี่เราโดนเรียกพี่สาวหรอ น้องเป็นเด็กดีจังเลย"},
		{"speaker": "น้องเป๊ก", "portrait": "CustomerC.png", "text": "นี่ๆ ผมเก็บเงินมาตลอด 10ปี เพื่อมากินเลยนะครับ เพราะงั้นวันนี้ผมจะกินให้เต็มที่เลย!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ว้าว เก่งจังเลย คุณน้องอยากจะสั่งอะไรดีคะ"},
		{"speaker": "น้องเป๊ก", "portrait": "CustomerC.png", "text": "แน่นอน ผมเก่งอยู่แล้ว! งั้นผมขอสั่งถ้วยใหญ่ 2 รสเลยครับ! เอาพิสตาชิโอ กับสตรอเบอร์รี่ชีสเค้ก แล้วขอท็อปปิ้งสตรอเบอร์รี่ด้วยครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้แล้วจ้า"},
		{"speaker": "น้องเป๊ก", "portrait": "CustomerC.png", "text": "ขอบคุณครับพี่คนสวย ไว้ผมจะมาใหม่นะครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) เอ๊ะ ทำไมรู้สึกเด็กคนนี้ดูInwza007จังนะ"},
	],

	# --- Day 4: คุยกับคุณลุงเรื่องงานร้านและลูกค้าย่านนี้ ---
	"day4": [
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "หลานเอ้ย เป็นไง เหนื่อยมั้ยกับงานร้านนี้"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ไม่เหนื่อยเลยค่ะ ทำไปเรื่อยๆ ก็สนุกดีเหมือนกัน"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) ถ้าไม่ใช่เพราะเจลาโต้ที่รัก ฉันคงไม่อยู่ตรงนี้หรอกนะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "แล้วหลานได้คุยกับลูกค้าบ้างมั้ย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ก็มีได้คุยบ้างเป็นบางคนค่ะ รู้สึกคนแถวนี้จะชอบกินเจลาโต้กันจริงๆ นะคะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "คนแถวนี้ก็อัธยาศัยดีแบบนี้แหละ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เอาล่ะ ถึงเวลาเปิดร้านแล้ว"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "โอเคค่ะ"},
	],

	# --- Day 5: นักศึกษาผู้รอดจากข้อสอบมาด้วยเจลาโต้ ---
	"day5": [
		{"speaker": "???", "portrait": "UniversityStudent.png", "text": "ไม่ไหวแล้ว ไม่ไหวแล้ว อาจารย์(static,linear)ออกข้อสอบอะไรไม่รู้ ยากมากเลย"},
		{"speaker": "???", "portrait": "UniversityStudent.png", "text": "ฮือ ฮือ หมดแรงแล้ว ร่างกายฉันต้องการน้ำตาล ชีวิตนี้ช่างโหดร้าย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "สวัสดีค่ะคุณลูกค้า!?"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "เอ่อ คุณลูกค้าโอเคมั้ยคะ?"},
		{"speaker": "อุ้ม", "portrait": "UniversityStudent.png", "text": "ฉันชื่ออุ้มค่ะ ร่างกายต้องการน้ำตาลด่วนเลยค่ะ จะไม่ไหวแล้ว... ขอถ้วยเล็ก ดาร์กช็อกโกแลต แล้วเพิ่มท็อปปิ้งคุกกี้ค่ะ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้แล้วค่ะ"},
		{"speaker": "อุ้ม", "portrait": "UniversityStudent.png", "text": "อ้า นี่สินะของหวานหลังจากเจอนรกอันโหดร้าย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) เหมือนเห็นตัวเองตอนสมัยยังเรียนไม่จบเลย พี่เข้าใจน้องเลยนะ ต่อให้ต้องกลับไปเรียนอีกก็ไม่ยากอะไรแล้ว"},
	],

	# --- Day 6: พนักงานออฟฟิศหนุ่มแว่นจากตึกข้างๆ ---
	"day6": [
		{"speaker": "", "portrait": "", "text": "..."},
		{"speaker": "", "portrait": "", "text": "*เดินเข้ามาในร้าน*"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) หนุ่มแว่นล่ะ หล่อจังเลย... ไม่ไม่ สนใจลูกค้าก่อน อย่าเพิ่งเขิน"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "สวัสดีค่ะ รับอะไรดีคะ"},
		{"speaker": "???", "portrait": "Employee.png", "text": "อะ อืม... สวัสดีครับผมชื่อคิวครับ ผมขอโคนรสพิสตาชิโอครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้แล้วค่ะ จะว่าไปแล้ว คุณทำงานแถวนี้หรอคะ ปกติไม่ค่อยเห็นเลย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) กรี๊ด ฉันชวนเขาคุยแล้ว! ทำยังไงดี ตายแล้ว เขินจัง หนุ่มแว่นตรงสเปคเป๊ะเลย"},
		{"speaker": "คิว", "portrait": "Employee.png", "text": "ครับ? อ้อ ใช่ครับ ผมทำงานที่บริษัทข้างๆ นี้เอง"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "งั้นหรอคะ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) ทำไงดีนะ จะชวนเขาคุยต่อยังไงดีล่ะ"},
		{"speaker": "คิว", "portrait": "Employee.png", "text": "ครับ งั้นไว้เจอกันอีกนะครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) เจอกันอีก?? จะได้เจอกันอีกใช่ไหมคะคุณพี่ คุ้มค่าแล้วที่คุณลุงให้มาดูแลร้านต่อ ได้เจอหนุ่มแว่นแบบนี้ด้วย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ค่ะ ค่ะ โชคดีค่ะ"},
	],


	# --- ลูกค้าพิเศษสุ่มรายวัน ---
	"special_day0": [
		{"speaker": "???", "portrait": "CustomerA.png", "text": "*กริ่ง* ร้านกลับมาเปิดแล้วจริงๆ สินค้าขึ้นชื่อของที่นี่ต้องลองสักหน่อย!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ยินดีต้อนรับค่ะ วันนี้รับอะไรดีคะ"},
		{"speaker": "ลูกค้าพิเศษ", "portrait": "CustomerA.png", "text": "ขอโคนรสช็อกโกแลตมินต์หนึ่งอันครับ อยากลองรสต้นตำรับของร้าน"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้เลยค่ะ เดี๋ยวจัดให้เลย!"},
	],
	"special_day1": [
		{"speaker": "???", "portrait": "CustomerB.png", "text": "วันนี้อยากให้รางวัลตัวเองหน่อย ร้านนี้มีท็อปปิ้งแล้วใช่ไหมนะ?"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "มีแล้วค่ะ อยากได้แบบไหนบอกได้เลยนะคะ"},
		{"speaker": "ลูกค้าพิเศษ", "portrait": "CustomerB.png", "text": "งั้นเอาถ้วยเล็กคุกกี้แอนด์ครีม เพิ่มท็อปปิ้งคุกกี้ครับ!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "รับออเดอร์ค่ะ!"},
	],
	"special_day2": [
		{"speaker": "???", "portrait": "CustomerD.png", "text": "ได้ยินว่าร้านนี้กลับมาเปิดแล้ว แถมมีรสใหม่ครบเลยนี่นา"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ใช่ค่ะ วันนี้มีครบทั้ง 6 รสแล้ว รับอะไรดีคะ"},
		{"speaker": "ลูกค้าพิเศษ", "portrait": "CustomerD.png", "text": "ขอถ้วยใหญ่ เลมอนกับพิสตาชิโอ แล้วเพิ่มท็อปปิ้งถั่วครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ได้เลยค่ะ!"},
	],
	"special_day4": [
		{"speaker": "???", "portrait": "CustomerF.png", "text": "ช่วงนี้ทำงานหนักมาก ขออะไรหวานๆ เติมพลังหน่อยแล้วกัน"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "รับอะไรดีคะ วันนี้ร้านเรามีครบทุกอย่างเลยค่ะ"},
		{"speaker": "ลูกค้าพิเศษ", "portrait": "CustomerF.png", "text": "ขอโคนดาร์กช็อกโกแลต เพิ่มท็อปปิ้งสตรอเบอร์รี่ครับ"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "รับทราบค่ะ!"},
	],
	"special_day7": [
		{"speaker": "???", "portrait": "CustomerA.png", "text": "เห็นคนพูดถึงร้านนี้เยอะมาก วันนี้เลยต้องมาลองด้วยตัวเอง"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ขอบคุณที่แวะมานะคะ อยากลองเมนูไหนเป็นพิเศษไหมคะ"},
		{"speaker": "ลูกค้าพิเศษ", "portrait": "CustomerA.png", "text": "เอาแบบจัดเต็มครับ! ถ้วยใหญ่ สตรอเบอร์รี่ชีสเค้กกับดาร์กช็อกโกแลต แล้วเพิ่มท็อปปิ้งคุกกี้"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "จัดให้เลยค่ะ!"},
	],

	# --- Ending: ปิดฉากตำนานร้านเจลาโต้ในมือเรา ---
	"ending": [
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "คงจะชินแล้วสินะหลาน"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "ทำได้คล่องแคล่วเหมือนเปิดร้านมาแล้ว 10 ปีเลยค่ะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ฮะฮะ ขยันเล่นมุกดีนี่ ลุงมีข่าวดีจะมาบอกล่ะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "ในเมื่อหลานดูแลร้านนี้ด้วยดีขนาดนี้ ลุงเลยว่าจะไปพักผ่อนที่อิตาลีนะ เพราะงั้นฝากร้านด้วยนะ ไปก่อนล่ะ!"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "คะ คะ!! เดี๋ยวก่อนคุณลุง!! ...อ่าว ไปแล้ว"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) ไหนว่าปวดหลังไง ทำไมดูเหมือนคนไม่เจ็บปวดอะไรเลย"},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) นี่เราโดนหลอกมาทำงานหรือเปล่านะ..."},
		{"speaker": "แพรวา", "portrait": "Player.png", "text": "(คิดในใจ) คงไม่หรอกมั้ง"},
		{"speaker": "", "portrait": "", "text": "คุณลุงที่ตอนนี้ไปพักผ่อนอยู่อิตาลีส่งข้อความมาว่าจะอยู่ที่นั่นอีกนานกว่าจะกลับ เพราะงั้นเลยยกร้านเจลาโต้ให้เป็นของเราแล้ว \"ฝากด้วยนะหลานรัก\""},
		{"speaker": "", "portrait": "", "text": "ทำให้ตอนนี้เราเป็นเจ้าของร้าน Good GoodsS gellato house เต็มตัวแล้ว เอาล่ะ ต่อไปก็ได้เวลาเปิดร้านแล้วสินะ... มาพยายามทำให้ดีที่สุดกันเลยดีกว่า!"},
	],
}

# ก่อนเริ่มด่านไหน (level_id) ให้เล่นตอนไหนก่อน (ครั้งแรกเท่านั้น)
# day0-day6 เล่นก่อนด่าน 1-7 ตามลำดับ ส่วน "ending" เล่นหลังจบด่าน 8 (ด่านสุดท้าย) ผ่าน Results.gd
const LEVEL_INTRO_CHAPTERS := {
	0: "day0",
	1: "day1",
	2: "day2",
	4: "day4",
}

# ลูกค้าพิเศษ: เมื่อสุ่มเจอจะเปิด Visual Novel ก่อน แล้วกลับมาพร้อมออเดอร์ที่ระบุไว้ตรงนี้
# reward_multiplier > 1 ทำให้ลูกค้าพิเศษจ่ายเงินมากกว่าลูกค้าปกติ
const SPECIAL_CUSTOMERS := {
	"special_day0": {"portrait": "CustomerA.png", "order": {"container": "cone", "flavors": ["choc_mint"], "toppings": []}, "reward_multiplier": 2.5},
	"special_day1": {"portrait": "CustomerB.png", "order": {"container": "small_cup", "flavors": ["cookies_cream"], "toppings": ["cookie"]}, "reward_multiplier": 2.5},
	"special_day2": {"portrait": "CustomerD.png", "order": {"container": "large_cup", "flavors": ["lemon", "pistachio"], "toppings": ["peanuts"]}, "reward_multiplier": 2.5},
	"day3": {"portrait": "CustomerC.png", "order": {"container": "large_cup", "flavors": ["pistachio", "strawberry_cheesecake"], "toppings": ["strawberry"]}, "reward_multiplier": 2.5},
	"special_day4": {"portrait": "CustomerF.png", "order": {"container": "cone", "flavors": ["dark_chocolate"], "toppings": ["strawberry"]}, "reward_multiplier": 2.5},
	"day5": {"portrait": "UniversityStudent.png", "order": {"container": "small_cup", "flavors": ["dark_chocolate"], "toppings": ["cookie"]}, "reward_multiplier": 2.5},
	"day6": {"portrait": "Employee.png", "order": {"container": "cone", "flavors": ["pistachio"], "toppings": []}, "reward_multiplier": 2.5},
	"special_day7": {"portrait": "CustomerA.png", "order": {"container": "large_cup", "flavors": ["strawberry_cheesecake", "dark_chocolate"], "toppings": ["cookie"]}, "reward_multiplier": 2.5},
}


const RANDOM_CUSTOMER_STORIES := {
	0: "special_day0",
	1: "special_day1",
	2: "special_day2",
	3: "day3",
	4: "special_day4",
	5: "day5",
	6: "day6",
	7: "special_day7",
}



static func portrait_path(file_name: String) -> String:
	return P + file_name
