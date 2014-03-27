//delete single photo in album
function removePhoto(element) {
    //event.preventDefault();
    var name = $(element).attr('rel');
    //alert(name);
    $.ajax({
        type: "DELETE",
        url: '/admin/album/removePhoto/' + $(element).attr('rel')
    }).done(function(response) {
        if (response.success) {
            //delete photo in canvas
            $("#" + name.split('.')[0]).remove();
        } else {
            alert('Error: ' + response.msg);
        }
    });
}

// Delete Blog
function deleteUser(event) {


    event.preventDefault();

    // Pop up a confirmation dialog
    var confirmation = confirm('Are you sure you want to delete this User:' + $(this).attr('rel') + '-' + $(this).attr('rev') + '?');

    // Check and make sure the user confirmed
    if (confirmation === true) {

        // If they did, do our delete
        $.ajax({
            type: 'DELETE',
            url: '/admin/blog/user/' + $(this).attr('rel'),
            data: {
                rev: $(this).attr('rev')
            }
        }).done(function(response) {

            // Check for a successful (blank) response
            if (response.msg === '') {} else {
                alert('Error: ' + response.msg);
            }

            // Update the table
            //populateTable();

        });

        document.location.href = "/admin/user/index";

    } else {

        // If they said no to the confirm, do nothing
        return false;

    }

}


// Delete Blog
function deleteBlog(event) {


    event.preventDefault();

    // Pop up a confirmation dialog
    var confirmation = confirm('Are you sure you want to delete this Blog:' + $(this).attr('rel') + '-' + $(this).attr('rev') + '?');

    // Check and make sure the user confirmed
    if (confirmation === true) {

        // If they did, do our delete
        $.ajax({
            type: 'DELETE',
            url: '/admin/blog/delete/' + $(this).attr('rel'),
            data: {
                rev: $(this).attr('rev')
            }
        }).done(function(response) {

            // Check for a successful (blank) response
            if (response.msg === '') {} else {
                alert('Error: ' + response.msg);
            }

            // Update the table
            //populateTable();

        });

        document.location.href = "/admin/blog/index";

    } else {

        // If they said no to the confirm, do nothing
        return false;

    }

}

// Delete User
function deleteLink(event) {


    event.preventDefault();

    // Pop up a confirmation dialog
    var confirmation = confirm('Are you sure you want to delete this link:' + $(this).attr('rel') + '-' + $(this).attr('rev') + '?');

    // Check and make sure the user confirmed
    if (confirmation === true) {

        // If they did, do our delete
        $.ajax({
            type: 'DELETE',
            url: '/admin/link/delete/' + $(this).attr('rel'),
            data: {
                rev: $(this).attr('rev')
            }
        }).done(function(response) {

            // Check for a successful (blank) response
            if (response.msg === '') {} else {
                alert('Error: ' + response.msg);
            }

            // Update the table
            //populateTable();

        });

        document.location.href = "/admin/link/index";

    } else {

        // If they said no to the confirm, do nothing
        return false;
    }
}

function deleteAlbum(event) {


    event.preventDefault();

    // Pop up a confirmation dialog
    var confirmation = confirm('Are you sure you want to delete this Album:' + $(this).attr('rel') + '-' + $(this).attr('rev') + '?');

    // Check and make sure the user confirmed
    if (confirmation === true) {

        // If they did, do our delete
        $.ajax({
            type: 'DELETE',
            url: '/admin/album/delete/' + $(this).attr('rel'),
            data: {
                rev: $(this).attr('rev')
            }
        }).done(function(response) {

            // Check for a successful (blank) response
            if (response.msg === '') {} else {
                alert('Error: ' + response.msg);
            }

            // Update the table
            //populateTable();

        });

        document.location.href = "/admin/album/index";

    } else {

        // If they said no to the confirm, do nothing
        return false;
    }
}


function confirmPassword(event) {
    event.preventDefault();
    var array = [];
    var pwd = $("input:password[name='password']").val();
    var c_pwd = $("input:password[name='c_password']").val();
    if (pwd == "" || c_pwd == "")
        return;
    if (pwd == c_pwd) {
        $("i[rel='isValid']").each(function() {
            //alert($(this).attr("style").val());
            $("i[rel='isValid']").attr("class", "fa fa-check-square");
            this.style.display = 'block';
            $("input:hidden").val("true");
        });
        //$("span[rel='isValid']").att("style").val("display:block");
    } else {
        $("i[rel='isValid']").each(function() {
            //alert($(this).attr("style").val());
            $("i[rel='isValid']").attr("class", "fa fa-times-circle");
            $("input:hidden").val("false");
        });
    }
}

function submitUser(event) {
    event.preventDefault();
    // Pop up a confirmation dialog
    var confirmation = confirm('Are you sure you want to add this user?');

    // Check and make sure the user confirmed
    if (confirmation === true) {

        var checked = $("input:hidden").val();
        if (checked == "true") {
            $("form[name='addUser']").submit();
        } else {
            alert("Error password");
            $("i[rel='isValid']").attr("class", "fa fa-times-circle");
            $("i[rel='isValid']").attr('style', "display:block;margin-left:3px;width:10px;");
        }
    } else {
        return;
    }
};