

gs.contests = {

    contest_id: null,

    current_open_panel_id: null,

    detail_info: function(id) {
        return {
            assoc_div: $('associated-'+id),
            unreg_div: $('unregistered-'+id),
            inactive_div: $('inactive-'+id)
        }
    },

    open_detail: function(id) {
        map = this.detail_info(id)

        if(this.current_open_panel_id){
            open = this.detail_info(this.current_open_panel_id)
            open.assoc_div.hide();
            open.unreg_div.hide();
            open.inactive_div.hide();
        }
        if(this.current_open_panel_id != id){
            map.assoc_div.show();
            map.unreg_div.show();
            map.inactive_div.show();
            this.current_open_panel_id = id;
        }else{
            //just closing
            this.current_open_panel_id = null;
        }

    }


}