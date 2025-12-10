const autofactura = {};
async function updateTunnel() {
	 try {
			let gist = xover.manifest.session.gist;
			if (!gist) return;
			await fetch(gist)
				 .then(res => res.text())
				 .then(gist => {
						gist = xover.json.tryParse(gist);
						xover.session.server = gist["tunnel"] || gist;
				 })
			if (!xover.session.server) xover.session.server = prompt("Proporcione la dirección del túnel")
	 } catch (e) {
			console.error(e)
	 }
}


let currentCalendarFinish = null;

function openCalendar({ label, defaultDate, maxDate }) {
	 return new Promise(resolve => {
			let modal = top.document.querySelector('#calendarModal');
			let labelEl = modal.querySelector('label');
			let input = modal.querySelector('#rangePicker');
			let btnClear = modal.querySelector('#btnCalendarClear');
			let btnClose = modal.querySelector('#btnCalendarClose');

			labelEl.innerText = label || 'Filtrar por rango';

			// Limpiar estado previo
			rangeSeparator = " al ";
			input.value = '';
			if (input._flatpickr) {
				 input._flatpickr.destroy();
			}

			let finished = false;
			function finish(value) {
				 if (finished) return;
				 finished = true;

				 if (input._flatpickr) {
						input._flatpickr.destroy();
				 }

				 modal.style.display = 'none';
				 currentCalendarFinish = null;
				 resolve(value || {});
			}

			const fp = flatpickr(input, {
				 mode: "range",
				 dateFormat: "Y-m-d",
				 rangeSeparator,
				 defaultDate,
				 maxDate,

				 onClose(selectedDates, dateStr, instance) {
						let srcElement = (event.srcElement || {}).nodeType === Node.ELEMENT_NODE ? event.srcElement : null;

						// Solo cuando hay dos fechas cerramos y resolvemos
						if (selectedDates.length === 2) {
							 if (srcElement && event.srcElement.matches("#btnCalendarClear")) {
									instance.clear();
									selectedDates = [];
							 }
							 selectedDates = selectedDates.map(item => instance.formatDate(item, "Y-m-d"));
							 let [from, to] = selectedDates;
							 finish({
									selectedDates,
									dateStr,
									from,
									to
							 });
						}
						// Si se cierra sin rango completo, no cerramos el modal ni resolvemos
				 }
			});

			currentCalendarFinish = finish;

			// 🔹 Botón borrar: limpia selección y deja el calendario listo
			if (btnClear) {
				 btnClear.onclick = function () {
						fp.clear();      // limpia selección + input
						input.focus();   // opcional
						fp.open();       // opcional: mantener visible el calendario
				 };
			}

			// 🔹 Botón cerrar: cancela y cierra
			if (btnClose) {
				 btnClose.onclick = function () {
						finish(null);
				 };
			}

			modal.style.display = 'block';
			fp.open();
	 });
}

function closeCalendar() {
	 if (typeof currentCalendarFinish === 'function') {
			currentCalendarFinish(null);
	 } else {
			let modal = top.document.querySelector('#calendarModal');
			if (modal) modal.style.display = 'none';
	 }
}