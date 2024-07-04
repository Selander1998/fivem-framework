$(document).ready(function () {
	window.addEventListener("message", function (event) {
		if (event.data.action == "update") {
			var data = event.data;
			$(".money-cash").fadeIn(150);
			$(".money-cash").css("display", "block");
			$("#cash").html(data.cash + ":-");
			if (data.minus) {
				$(".money-cash").append(
					'<p class="moneyupdate minus">-<span><span id="minus-changeamount">' +
						data.amount +
						":-</span></span></p>"
				);
				$(".minus").css("display", "block");
				setTimeout(function () {
					$(".minus").fadeOut(750, function () {
						$(".minus").remove();
						$(".money-cash").fadeOut(750);
					});
				}, 3500);
			} else {
				$(".money-cash").append(
					'<p class="moneyupdate plus">+<span><span id="plus-changeamount">' +
						data.amount +
						":-</span></span></p>"
				);
				$(".plus").css("display", "block");
				setTimeout(function () {
					$(".plus").fadeOut(750, function () {
						$(".plus").remove();
						$(".money-cash").fadeOut(750);
					});
				}, 3500);
			}
		}

		if (event.data.type != null && event.data.text != null) {
			var $notification = CreateNotification(event.data);
			$(".notif-container").append($notification);
			setTimeout(
				function () {
					$.when($notification.fadeOut()).done(function () {
						$notification.remove();
					});
				},
				event.data.length != null ? event.data.length : 5000
			);
		}
	});
});

function CreateNotification(data) {
	var $notification = $(document.createElement("div"));
	$notification.addClass("notification").addClass(data.type);
	$notification.html(
		'<hr style="position: relative; margin-top: -3%;"><p style="margin-top: 3%; font-size: 15px;">' +
			data.text +
			"</p>"
	);
	$notification.fadeIn();
	if (data.style !== undefined) {
		Object.keys(data.style).forEach(function (css) {
			$notification.css(css, data.style[css]);
		});
	}
	return $notification;
}
