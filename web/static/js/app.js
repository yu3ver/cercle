// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import "bootstrap-datepicker"
import icheck from "./adminlte/plugins/iCheck/icheck.min"
import slimscroll from "./adminlte/plugins/slimScroll/jquery.slimscroll.min"
import fastclick from "./adminlte/plugins/fastclick/fastclick"
import adminlte from "./adminlte/dist/js/app.min"

import socket from "./socket"
import selectize from "./selectize"
import { Activity } from "./activity"
import contact_add from "./contact_add"
import { ContactEdit } from "./contact_edit"
import contact_live from "./contact_live"
import { Pipeline } from "./opportunity_pipeline"

export var App = {
  activity_init: function(){
    Activity.start()
  },
  pipeline_init: function(){
    Pipeline.start()
  },
  contact_edit_init: function(){
    ContactEdit.start();
  },
  contact_socket_init: function(){
    // LOAD SOCKET
    var contact_id = $('#contact_id').data("id");
    contact_live.init(socket, contact_id );
    // LOAD CHANGE COMPANY SELECTOR
  }
}
