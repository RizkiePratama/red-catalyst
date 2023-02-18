$(document).ready(function() {
    $('#Overlay').change(function(){
        if($(this).val() == "none") {
            $('#OverlayOptions').hide();
            $('#OverlayMode').removeAttr('required');
            $('#OverlayMode').removeAttr('data-error');
        } else {
            $('#OverlayOptions').show()
            $('#OverlayMode').attr('required', '');
            $('#OverlayMode').attr('data-error', 'This field is required.');
        }
    });
    $("#Overlay").trigger("change");

    $('#OverlayMode').change(function(){
        if($(this).val() == "absolute") {
            $('#OverlayPos').show()
            $('#OverlayPosX').attr('required', '');
            $('#OverlayPosX').attr('data-error', 'This field is required.');
            $('#OverlayPosY').attr('required', '');
            $('#OverlayPosY').attr('data-error', 'This field is required.');
        } else {
            $('#OverlayPos').hide();
            $('#OverlayPosX').removeAttr('required');
            $('#OverlayPosX').removeAttr('data-error');
            $('#OverlayPosY').removeAttr('required');
            $('#OverlayPosY').removeAttr('data-error');
        }
    });
    $("#OverlayMode").trigger("change");
});