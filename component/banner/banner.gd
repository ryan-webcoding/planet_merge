extends Node2D

var _ad_view : AdView

func _ready():
	MobileAds.initialize()
	_create_ad_view()
	_register_ad_listener()
	_load_banner()

func _create_ad_view() -> void:
	if _ad_view:
		_destroy_ad_view()  # Clean up if already exists

	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111"  # Test Android banner
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/2934735716"  # Test iOS banner

	_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM)

func _load_banner() -> void:
	if _ad_view == null:
		_create_ad_view()

	var ad_request := AdRequest.new()
	_ad_view.load_ad(ad_request)

func _register_ad_listener() -> void:
	if _ad_view != null:
		var ad_listener := AdListener.new()

		ad_listener.on_ad_failed_to_load = func(load_ad_error : LoadAdError) -> void:
			print("❌ Ad failed to load: ", load_ad_error.message)
			# Retry loading
			_load_banner()

		ad_listener.on_ad_clicked = func() -> void:
			print("👉 Ad clicked (handled by AdMob)")

		ad_listener.on_ad_closed = func() -> void:
			print("📴 Ad closed")

		ad_listener.on_ad_impression = func() -> void:
			print("👁️ Ad impression")

		ad_listener.on_ad_loaded = func() -> void:
			print("✅ Ad loaded")

		ad_listener.on_ad_opened = func() -> void:
			print("📂 Ad opened")

		_ad_view.ad_listener = ad_listener

func _destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null
