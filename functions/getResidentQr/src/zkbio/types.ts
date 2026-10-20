export interface ZkBioConfig {
  serverUrl: string;
  serverPort: number;
  accessToken: string;
}

export interface ZkBioResponse<T = unknown> {
  code: number;
  message: string;
  data: T;
}

export interface SocietyZkBioDoc {
  zkbioEnabled?: boolean;
  zkbioServerUrl?: string;
  zkbioServerPort?: number;
  defaultAccLevelIds?: string[];
  defaultVisLevelIds?: string[];
  amenityAccLevelMap?: Record<string, string>;
}

export interface ResidentDoc {
  userID?: string;
  userName?: string;
  societyID?: string;
  status?: number;
  zkPin?: string;
  zkAccLevelIds?: string[];
  zkProvisionedAt?: FirebaseFirestore.Timestamp;
}

export interface VisitorDoc {
  name?: string;
  contact?: string;
  visitorType?: string;
  fromDateTime?: FirebaseFirestore.Timestamp;
  toDateTime?: FirebaseFirestore.Timestamp;
  zkVisEmpPin?: string;
  zkCertNum?: string;
  zkRegisteredAt?: FirebaseFirestore.Timestamp;
  zkCheckedOutAt?: FirebaseFirestore.Timestamp;
}

export interface AccessRequestDoc {
  requestByUID?: string;
  societyID?: string;
  requestedAccessTitle?: string;
  status?: string;
  requestedForDate?: string;
  requestedForTime?: string;
}

export interface QrResult {
  qrPayload: string;
  fetchedAt: string;
}

export interface RegisterGuestResult extends QrResult {
  zkVisEmpPin: string;
  zkCertNum: string;
}
