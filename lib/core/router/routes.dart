const rootRoute = "/";

// DASHBOARD //
const dashboardPageName = "Dashboard";
const dashboardPageRoute = "/dashboard";

// QUẢN LÝ NGƯỜI CHƠI //
const accountListPageName = "Account List";
const accountListPageRoute = "/acc_list";

// QUẢN LÝ ĐẶT LỊCH //
const bookingPageName = "Booking";
const bookingPageRoute = "/booking";

// QUẢN LÝ GHÉP ĐỘI //
const matchMakingPageName = "Match";
const matchMakingPageRoute = "/match";

// QUẢN LÝ STATION //
const stationPageName = "Stationn";
const stationPageRoute = "/station";

// QUẢN LÝ SPACE - LOẠI HÌNH //
const spacePageName = "Space";
const spacePageRoute = "/space";

// QUẢN LÝ AREA - KHU VỰC //
const areaPageName = "Area";
const areaPageRoute = "/area";

// QUẢN LÝ PROPERTY - TÀI NGUYÊN //
const propertyPageName = "Property";
const propertyPageRoute = "/property";

// QUẢN LÝ MENU - DV ĂN UỐNG//
const menuPageName = "Menu";
const menuPageRoute = "/menu";

// QUẢN LÝ STAFF - NHÂN VIÊN//
const staffPageName = "Staff";
const staffPageRoute = "/staff";

// QUẢN LÝ PAYMENT - GIAO DỊCH//
const paymentPageName = "Payment";
const paymentPageRoute = "/payment";

// ĐĂNG XUẤT //
const logoutName = "Logout";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}

List<MenuItem> sideMenuItemRoutes = [
  MenuItem(dashboardPageName, dashboardPageRoute),
  MenuItem(accountListPageName, accountListPageRoute),
  MenuItem(bookingPageName, accountListPageRoute),
  MenuItem(matchMakingPageName, accountListPageRoute),
  MenuItem(stationPageName, accountListPageRoute),
  MenuItem(spacePageName, accountListPageRoute),
  MenuItem(areaPageName, accountListPageRoute),
  MenuItem(propertyPageName, accountListPageRoute),
  MenuItem(menuPageName, accountListPageRoute),
  MenuItem(staffPageName, accountListPageRoute),
  MenuItem(paymentPageName, accountListPageRoute),
];
