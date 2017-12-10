// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require select2
//= require toastr
//= require turbolinks
//= require notes
// require_tree .

function openNav() {
    document.getElementById("mySidenav").style.right = "0";
}

function closeNav() {
    document.getElementById("mySidenav").style.right = "-350px";
}

function autoSaveNote(text) {
    textarea = $('textarea.paper.edit-note');
    if (textarea.length == 1) {
      id = textarea.data('note-id');
      body = textarea.val();

      if(text != body){
        formData = { "note": {"body": body } }
        $.ajax({
          type: "PATCH",
          url:'/notes/' + id,
          data: formData,
          dataType: 'js'
        });

        note_body = body;
      }
    }
}
