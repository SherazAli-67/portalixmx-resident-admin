import { setGlobalOptions } from "firebase-functions/v2";
import { getResidentQr } from "./callables/getResidentQr";
import { registerGuestZkAccess } from "./callables/registerGuestZkAccess";
import { refreshGuestQr } from "./callables/refreshGuestQr";
import { checkoutGuestZkAccess } from "./callables/checkoutGuestZkAccess";
import { syncGuardAccessLogs } from "./callables/syncGuardAccessLogs";
import { onResidentStatusChange } from "./triggers/onResidentStatusChange";
import { onAccessRequestApproved } from "./triggers/onAccessRequestApproved";

setGlobalOptions({ region: "us-central1" });

export {
  getResidentQr,
  registerGuestZkAccess,
  refreshGuestQr,
  checkoutGuestZkAccess,
  syncGuardAccessLogs,
  onResidentStatusChange,
  onAccessRequestApproved,
};
