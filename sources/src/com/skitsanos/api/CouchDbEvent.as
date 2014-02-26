package com.skitsanos.api
{
	import flash.events.Event;

	public class CouchDbEvent extends Event
	{
		public static const ERROR:String = "couchdb_error";
		public static const VERSION:String = "couchdb_version";
		public static const ACTIVE_TASKS:String = "couchdb_active_tasks";
		public static const ALL_DBS:String = "couchdb_all_dbs";
		public static const DB_EXIST:String = "couchdb_db_exist";
		public static const DB_CREATE:String = "couchdb_db_create";
		public static const DB_DELETE:String = "couchdb_db_delete";
		public static const REPLICATE:String = "couchdb_replicate";
		public static const ALL_DOCS:String = "couchdb_all_docs";
		public static const DOCUMENTS_COUNT:String = "couchdb_docs_count";
		public static const DOCUMENT_EXISTS:String = "couchdb_docs_exist";
		public static const CREATE_DOCUMENT:String = "couchdb_docs_create";
		public static const UPDATE_DOCUMENT:String = "couchdb_docs_update";
		public static const COPY_DOCUMENT:String = "couchdb_docs_copy";
		public static const GET_DOCUMENT:String = "couchdb_docs_get";
		public static const DELETE_DOCUMENT:String = "couchdb_docs_delete";
		public static const BULK_DELETE_DOCUMENTS:String = "couchdb_docs_bulk_delete";
		public static const ATTACHMENT_EXIST:String = "couchdb_attachment_exist";
		public static const ATTACHMENT_INLINE_SET:String = "couchdb_attachment_inline_set";
		public static const ATTACHMENT_INLINE_GET:String = "couchdb_attachment_inline_get";
		public static const ATTACHMENT_INLINE_INFO:String = "couchdb_attachment_inline_info";
		public static const ATTACHMENT_INLINE_DELETE:String = "couchdb_attachment_inline_delete";
		public static const ALL_DESIGN_DOCS:String = "couchdb_all_design_docs";
		public static const DESIGN_CREATE:String = "couchdb_design_create";
		public static const VIEW_TEMP_CREATE:String = "couchdb_view_temp_create";
		public static const VIEW_CREATE:String = "couchdb_view_create";
		public static const SHOW_EXIST:String = "couchdb_show_exist";
		public static const SHOW_GET:String = "couchdb_show_get";
		public static const SHOW_SET:String = "couchdb_show_set";
		public static const SHOW_DELETE:String = "couchdb_show_delete";
		public static const LIST_EXIST:String = "couchdb_list_exist";
		public static const LIST_GET:String = "couchdb_list_get";
		public static const LIST_SET:String = "couchdb_list_set";
		public static const LIST_DELETE:String = "couchdb_list_delete";
		public static const GET_DESIGN_LIST:String = "couchdb_design_list_get";
		public static const VIEW_EXIST:String = "couchdb_view_exist";
		public static const VIEW_GET:String = "couchdb_view_get";
		public static const VIEW_SET:String = "couchdb_view_set";
		public static const DELETE_VIEW:String = "couchdb_view_delete";
		public static const VIEW_GET_MAP:String = "couchdb_view_get_map";
		public static const VIEW_GET_REDUCE:String = "couchdb_view_get_reduce";
        public static const VALIDATE_EXIST:String = "couchdb_validate_exist";
        public static const VALIDATE_GET:String = "couchdb_validate_get";
        public static const VALIDATE_SET:String = "couchdb_validate_set";
        public static const DELETE_VALIDATE:String = "couchdb_validate_delete";
        public static const REWRITE_GET:String = "couchdb_rewrite_get";
        public static const REWRITE_SET:String = "couchdb_rewrite_set";
        public static const DELETE_REWRITE:String = "couchdb_rewrite_delete";
        public static const FILTER_EXIST:String = "couchdb_filter_exist";
        public static const FILTER_GET:String = "couchdb_filter_get";
        public static const FILTER_SET:String = "couchdb_filter_set";
        public static const DELETE_FILTER:String = "couchdb_filter_delete";

        public static const USER_EXISTS:String = "couchdb_user_exists";
        public static const USER_ADD:String = "couchdb_user_add";
        public static const USER_GET:String = "couchdb_user_get";
        public static const USER_UPDATE:String = "couchdb_user_update";
        public static const USER_DELETE:String = "couchdb_user_delete";

		public var result:*;
		public var serverResponse:ServerResponse;

		public function CouchDbEvent(type:String, result:*, serverResponse:ServerResponse, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.result = result;
			this.serverResponse = serverResponse;
		}
	}
}