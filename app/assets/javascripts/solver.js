$(function() {

		var d1 = [];
		for (var i = 0; i < 14; i += 0.1) {
			d1.push([i, Math.sin(i)]);
		}

		$.plot("#placeholder", [d1]);

	});
