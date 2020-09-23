namespace Enza.UTM.Entities
{
    public class AppRoles
    {
        public const string ADMIN = "admin";
        public const string MANAGE_MASTER_DATA_UTM = "managemasterdatautm";
        public const string REQUEST_TEST = "requesttest";
        public const string HANDLE_LAB_CAPACITY = "handlelabcapacity";
        public const string PUBLIC = ADMIN + "," + MANAGE_MASTER_DATA_UTM + "," + REQUEST_TEST;
        public const string PUBLIC_EXCEPT_ADMIN = HANDLE_LAB_CAPACITY + "," + MANAGE_MASTER_DATA_UTM + "," + REQUEST_TEST;
        public const string MANAGE_MASTER_DATA_UTM_REQUEST_TEST = MANAGE_MASTER_DATA_UTM + "," + REQUEST_TEST;
        public const string UTM_IMPORT_EXTERNAL = "utm_importexternal";
        public const string UTM_S2S_DH_PRODUCTION = "utm_s2s_dh_production";
    }
}