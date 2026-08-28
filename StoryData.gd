extends RefCounted
class_name StoryData

# ------------------------------------------------------------
#  บทพูดของแต่ละตอน (chapter) ใช้โดย VisualNovel.tscn
#  พูดสลับกันแค่ 2 ตัวละครต่อตอน (อีกฝั่งคือ "เรา" = Player เสมอ)
# ------------------------------------------------------------

const P := "res://assets/characters/"

const CHAPTERS := {
	"intro": [
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "จำได้ไหม... ร้านนี้ลุงเปิดมาตั้งแต่เธอยังเดินไม่ได้เลยนะ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ลุงคะ หนูจะดูแลร้านให้เต็มที่เลยค่ะ!"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เจลาโต้ที่ดีไม่ใช่แค่หวานเย็น... ต้องตักให้ถูกจังหวะ เสิร์ฟให้ตรงใจลูกค้าด้วยนะ"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เอาล่ะ ลองดูฝีมือหน่อยสิ พร้อมรึยัง?"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "พร้อมค่ะ! ไปลุยกันเลย"},
	],
	"employee": [
		{"speaker": "เอิร์ธ", "portrait": "Employee.png", "text": "สวัสดีครับ ผมชื่อเอิร์ธ ลุงวาชิฝากมาช่วยที่ร้านครับ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ดีใจจังเลยค่ะ ตอนนี้ลูกค้าเริ่มเยอะขึ้นพอดี"},
		{"speaker": "เอิร์ธ", "portrait": "Employee.png", "text": "ผมจะคอยดูออเดอร์หลังร้านให้ ส่วนหน้าร้านฝากคุณนะครับ"},
		{"speaker": "เอิร์ธ", "portrait": "Employee.png", "text": "ลองรสชาติใหม่ๆ ดูสิครับ ลูกค้าจะได้ประทับใจมากขึ้น"},
	],
	"university": [
		{"speaker": "นิสิตสาว", "portrait": "UniversityStudent.png", "text": "พี่คะ ขอเจลาโต้แก้ง่วงหน่อยได้ไหมคะ ใกล้สอบแล้ว"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ได้เลยค่ะ! เดี๋ยวจัดรสเข้มๆ ให้ชื่นใจ"},
		{"speaker": "นิสิตสาว", "portrait": "UniversityStudent.png", "text": "ขอบคุณค่ะ ร้านนี้ช่วยชีวิตนักศึกษาจริงๆ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ยินดีเสมอค่ะ ลูกค้าประจำแบบนี้แหละที่ทำให้ร้านเราอบอุ่น"},
	],
	"influencer": [
		{"speaker": "อินฟลูฯสาว", "portrait": "Influencer.png", "text": "โอ้โห ร้านนี้น่ารักมาก ขอถ่ายรูปลงรีวิวหน่อยได้ไหมคะ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ได้เลยค่ะ ขอบคุณที่แวะมานะคะ"},
		{"speaker": "อินฟลูฯสาว", "portrait": "Influencer.png", "text": "เดี๋ยวลงรีวิวให้เลย ร้านนี้ต้องดังแน่ๆ!"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "หวังว่าทุกคนจะชอบรสชาติที่เราตั้งใจทำนะคะ"},
	],
	"ending": [
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "เธอทำได้ดีมากเลยนะ ร้านนี้อยู่ในมือเธอแล้วล่ะ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ขอบคุณที่ไว้ใจหนูนะคะลุง หนูจะดูแลร้านนี้ต่อไปให้ดีที่สุด"},
		{"speaker": "ลุงวาชิ", "portrait": "ShopOwner.png", "text": "งั้นลุงขอไปพักผ่อนบ้างล่ะ... ฝากร้านด้วยนะ"},
		{"speaker": "เรา", "portrait": "Player.png", "text": "ฝากไว้เลยค่ะ Good Goods Gelato House จะดังไปทั่วโลกแน่นอน!"},
	],
}

# ก่อนเริ่มด่านไหน (level_id) ให้เล่นตอนไหนก่อน (ครั้งแรกเท่านั้น)
const LEVEL_INTRO_CHAPTERS := {
	0: "intro",
	2: "employee",
	4: "university",
	6: "influencer",
}


static func portrait_path(file_name: String) -> String:
	return P + file_name
