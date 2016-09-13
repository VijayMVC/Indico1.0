/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* This will search the text with case insencitive */
jQuery.expr[':'].contains = function (a, i, m) {
    return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

// Bootstrap Tooltip
$('a').tooltip();

// Button Button Loading State
$('button[data-loading-text]').click(function () {
    $(this).button('loading');
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Init page drag and drop file upload if contain */
$(document).ready(function () {

    $('.fileupload').each(function () {
        var suffix = $(this).attr('id').split('_')[1];
        var peview = $(this).hasClass('preview');
        var single = $(this).hasClass('single');
        var setdefault = $(this).hasClass('setdefault');
        var hidezone = $(this).hasClass('hide-dropzone');
        var maxcount = Number($(this).attr('maxcount')) || 100;
        var maxFileSze = Number($(this).attr('maxfilesize')) || 0; //Size in KB

        initFileUpload(suffix, peview, single, setdefault, hidezone, maxcount, maxFileSze);
        document.getElementById("filekey").value = Math.floor(Math.random(100, 999) * 1000);
    });

    function initFileUpload(suffix, peview, single, setdefault, hidezone, maxcount, maxFileSze) {
        $('#mainForm').fileUploadUI({
            url: '/FileUpload.ashx',
            method: 'POST',
            namespace: 'file_upload_' + suffix,
            fileInputFilter: '#file_' + suffix,
            dropZone: $('#dropzone_' + suffix),
            uploadTable: $('#uploadtable_' + suffix),
            downloadTable: $('#uploadtable_' + suffix),
            buildUploadRow: function (files, index) {
                /*var tableCount = $(files).length;
                var maxcount = parseInt(maxCount);
                if (tableCount > maxcount && (index > 0)) {
                return null;
                }*/
                var tableRowCount = $('#uploadtable_2 tbody tr').length;
                if ((single && (index > 0)) || (tableRowCount > 3)) {
                    return null;
                }
                if (hidezone) {
                    if (($('#dropzone_' + suffix).parent().hasClass('file_upload_controller')) == true) {
                        $('#dropzone_' + suffix).parent('div').hide();
                    }
                    else {
                        $('#dropzone_' + suffix).parent('div').hide();
                    }

                }
                return $('<tr><td>' + files[index].name + '<\/td>' +
                         '<td class="file_upload_progress"><div><\/div><\/td>' +
                         '<td class="file_cancel">' +
                         '<button class="ui-state-default ui-corner-all" title="Cancel">' +
                         '<span class="iicon icancel">Cancel<\/span>' +
                         '<\/button><\/td><\/tr>');
            },
            buildDownloadRow: function (file) {
                if ((maxFileSze > 0) && (Number(file.filesize) > maxFileSze)) {
                    //Show dropzone
                    if (($('#dropzone_' + suffix).parent().hasClass('file_upload_controller')) == true) {
                        $('#dropzone_' + suffix).parent('div').show();
                    }
                    else {
                        $('#dropzone_' + suffix).parent('li').show();
                    }
                    //Bind error message
                    $('#hdnIsValid_' + suffix).val('0');
                    var datarow = '<tr><td><div class="alert alert-error">File must be less than <strong>' + getFileSize(maxFileSze) + '</strong></td></tr>'
                    return $(datarow);
                }
                else {
                    document.getElementById("filekey").value = Math.floor(Math.random(100, 999) * 1000);
                    var extension = ((file.name).substring((file.name).lastIndexOf(".") + 1, (file.name).length)).toLowerCase();
                    var datarow = '<tr id="file_' + file.key + '"><td class="file_preview">';

                    switch (extension) {
                        case "css":
                        case "doc":
                        case "docx":
                        case "eps":
                        case "pdf":
                        case "pps":
                        case "ppt":
                        case "pptx":
                        case "psd":
                        case "rar":
                        case "rm":
                        case "tif":
                        case "tiff":
                        case "txt":
                        case "xls":
                        case "xlsx":
                        case "xml":
                        case "zip":
                            {
                                datarow += '<img src="../' + dataFolderName + '/FileTypes/' + extension + '.gif" \/><\/td>';
                                break;
                            }
                        case "bmp":
                        case "gif":
                        case "jpg":
                        case "jpeg":
                        case "png":
                            {
                                if (peview) {
                                    datarow += '<img src="../' + dataFolderName + '/temp/' + document.getElementById(subfolder).value + '/' + file.url + '" height="' + file.height + '" width="' + file.width + '" \/><\/td>';
                                }
                                else {
                                    datarow += '<img src="../' + dataFolderName + '/FileTypes/' + extension + '.gif" \/><\/td>';
                                }
                                break;
                            }
                        case "swf":
                            {
                                if (peview) {
                                    datarow += '<object data="../' + dataFolderName + '/temp/' + document.getElementById(subfolder).value + '/' + file.url + '" height="' + file.height + '" width="' + file.width + '" type="application/x-shockwave-flash">' +
                                           '<param name="movie" value="../' + dataFolderName + '/temp/' + document.getElementById(subfolder).value + '/' + file.url + '" \/><param name="wmode" value="opaque"></object><\/td>';
                                }
                                else {
                                    datarow += '<img src="../' + dataFolderName + '/FileTypes/' + extension + '.gif" \/><\/td>';
                                }
                                break;
                            }
                        default:
                            {
                                datarow += '<img src="../' + dataFolderName + '/FileTypes/unknown.gif" \/><\/td>';
                                break;
                            }
                    }
                    datarow += '<td class="file_name">' + file.name + '</td>' +
                           '<td class="file_size">' + file.size + '</td>' +
                           '<td><a href="javascript:void(0)" class="btn-link idelete" onclick="removeFile(this, ' + setdefault + ', \'' + file.url + '\', \'' + file.name + '\', \'' + hidezone + '\', \'' + suffix + '\')" data-original-title="Delete"><i class="icon-trash "></i><\/a><\/td>' +
                           '<\/tr>'; //  class="file_delete"
                    return $(datarow);
                }
            },
            beforeSend: function (event, files, index, xhr, handler, callBack) {
                if (single && (index > 0)) {
                    return;
                }
                callBack();
            }
        });
    }
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

function getFileSize(size) {
    if ((size / 1024) > 0.5) {
        return (size / 1024) + ' MB';
    }
    else {
        return size + ' KB';
    }
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Remove upload file */
function removeFile(o, setdefault, fileurl, filename, hidezone, suffix) {
    var replaceValue = $(o).parents('table.file_upload_files').next('input[type=hidden]')[0].value;
    if (setdefault) {
        //
        //$(o).parents('table.file_upload_files').prev('div').show();
        $(o).parents('table.file_upload_files').prev('label').show();
        replaceValue = 'REMOVED';
    }
    else {
        replaceValue = replaceValue.replace(fileurl.toLowerCase() + ',' + filename + '|', '');
    }
    $(o).parents('table.file_upload_files').next('input[type=hidden]')[0].value = replaceValue;
    $(o).parents('tr').remove();

    if (hidezone) {
        if (($('#dropzone_' + suffix).parent().hasClass('file_upload_controller')) == true) {
            $('#dropzone_' + suffix).parent('div').show();
        }
        else {
            $('#dropzone_' + suffix).parent('div').show();
        }

    }
}
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Mouse hover image preview */
this.imagePreview = function () {
    /* CONFIG */
    xOffset = 20;
    yOffset = 20;
    // these 2 variable determine popup's distance from the cursor
    // you might want to adjust to get the right result
    var title;
    /* END CONFIG */
    $("a.preview").hover(function (e) {
        var content;
        if (this.href.indexOf('#') > -1) {
            content = "<div id='preview' class='content'>" + $(this.href.replace(window.location, ''))[0].innerHTML + "</div>";
            xOffset = 50;
        }
        else {
            var height, width;
            var attributes = $(this)[0].attributes;
            for (var i = 0; i < attributes.length; i++) {
                if (attributes[i].name == 'height') {
                    height = attributes[i].value;
                }
                else if (attributes[i].name == 'width') {
                    width = attributes[i].value;
                }
            }

            title = this.title
            this.title = "";
            var c = (title != "") ? "<td class='file_name'><span>" + title + "</span></td>" : "";

            content = "<table id='preview'><tr><td class='file-preview'>" +
                      "<img src='" + this.href + "' alt='Image preview' width='" + width + "' height='" + height + "' />" +
                      "</td>" + ((c != '') ? "<td>" + c + "</td>" : "") + "</tr></table>";
        }
        $("body").append(content);
        $("#preview").fadeIn("fast");
    },
	function () {
	    this.title = title;
	    $("#preview").remove();
	});
    $("a.preview").mousemove(function (e) {
        var xPos = (Number(e.pageX) + Number(xOffset));
        var yPos = (Number(e.pageY) /*- Number(yOffset)*/ - (Number($("#preview").height()) / 2));
        if ($(window).width() < (xPos + Number($("#preview").width()))) {
            xPos = (Number(e.pageX) - Number(xOffset) - Number($("#preview").width()));
        }
        //if ((yPos - Number($("#preview").height())) < 0) {
        //    yPos = (Number(e.pageY) + Number(yOffset));
        //}
        $("#preview").css("top", yPos + "px").css("left", xPos + "px");
        // (e.pageY - yOffset - height)	//(e.pageX + xOffset)
    });
};

// starting the script on page load
$(document).ready(function () {
    imagePreview();
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Color picker */
$(document).ready(function () {

    var colorPickers = $('.color-picker');
    for (var i = 0; i < colorPickers.length; i++) {
        if (colorPickers[i].id != '') {
            if (($('#' + colorPickers[i].id + ' div').length > 0) && ($('#' + colorPickers[i].id + ' input[type=hidden]').length > 0)) {
                var suffix = colorPickers[i].id.split('_')[1];
                initLayout(suffix);
            }
        }
    }
    function initLayout(suffix) {
        $('#colorPicker_' + suffix).ColorPicker({
            color: $('#colorPicker_' + suffix + ' input[type=hidden]')[0].value,
            onShow: function (colpkr) {
                $(colpkr).fadeIn(500);
                return false;
            },
            onHide: function (colpkr) {
                $(colpkr).fadeOut(500);
                return false;
            },
            onChange: function (hsb, hex, rgb) {
                $('#colorPicker_' + suffix + ' div').css('backgroundColor', '#' + hex);
                $('#colorPicker_' + suffix + ' input[type=hidden]')[0].value = '#' + hex;
            }
        });

    }
    EYE.register(initLayout, 'init');
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Reset fieldset textbox, textarea and dropdown list */
function resetFieldsDefault(s) {
    $('#' + s + ' fieldset input[type=text]').val('');
    $('#' + s + ' fieldset select').each(function () {
        $('option:selected', this).removeAttr('selected');
        $(this)[0].selectedIndex = 0;
    });
    $('#' + s + ' fieldset textarea').val('');
}
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/*Intiger text box */
$('.iintiger').keydown(function (e) {
    // Allow: backspace, delete, tab and escape
    if (e.keyCode == 46 || e.keyCode == 8 || e.keyCode == 9 || e.keyCode == 27 ||
        // Allow: Ctrl+A
       (e.keyCode == 65 && e.ctrlKey === true) ||
        // Allow: home, end, left, right
       (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }
    else {
        // Ensure that it is a number and stop the keypress
        if ((e.keyCode < 48 || e.keyCode > 57) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    }
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/* Double input text box */
$('.idouble').keydown(function (e) {
    // Allow: backspace, delete, tab and escape
    if (e.keyCode == 46 || e.keyCode == 8 || e.keyCode == 9 || e.keyCode == 27 ||
        // Allow: Ctrl+A
       (e.keyCode == 65 && e.ctrlKey === true) ||
        // Allow: home, end, left, right
       (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }
    else {
        // Ensure that it is a number and stop the keypress
        if ((e.keyCode == 110 || e.keyCode == 190)) {
            return;
        }
        else if ((e.keyCode < 48 || e.keyCode > 57) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    }
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

/*2012 - CUSTOM .checkbox-columns*/
$(document).ready(function () {
    if ($('table.checkbox-columns.vertical').length > 0) {
        var maxWidth = 0;
        $('table.checkbox-columns.vertical td label').each(function () {
            maxWidth = (($(this).width() + 60) > maxWidth) ? ($(this).width() + 60) : maxWidth;
        });
        var tableWidth = parseFloat($('table.checkbox-columns.vertical').width());
        var rows = parseInt($('table.checkbox-columns.vertical tr').length);
        var columns = Math.round(tableWidth / parseFloat(maxWidth));
        var rowWidth = parseFloat(tableWidth / columns);
        $('table.checkbox-columns.vertical tr').css('width', (100 / columns) + '%');
        $('table.checkbox-columns.vertical').css('height', (columns * 30) + 'px');
    }
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

$(document).ready(function () {
    $('.inprogress').click(function () {
        $('#waitingOverly').modal('show');
    });
});

$('.modal .modal-body').css('max-height', ($(window).height() * 0.6) + 'px');
$(window).resize(function () {
    $('.modal .modal-body').css('max-height', ($(window).height() * 0.6) + 'px');
});
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/