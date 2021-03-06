Jibe.events["meetings"] =
	afterCreate: (meeting, data, scope) ->
		Attendance.removeFirstColumn()
		Attendance.addEmptyColumn()
		meeting.insertBefore("#attendance_header th.row_for_new")
		$("#attendance_header").data("last-meeting-id", data.meeting_id)
		Attendance.hideMeetingArrows()
		Noterizer.open "Meeting was created."
	
	afterDestroy: (meeting, data, scope) ->
		window.location.reload()
		Noterizer.open "Meeting was deleted.", "fail"