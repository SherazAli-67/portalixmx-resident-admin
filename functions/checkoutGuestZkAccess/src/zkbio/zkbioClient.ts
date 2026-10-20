import axios, { AxiosInstance } from "axios";
import { ZkBioConfig, ZkBioResponse } from "./types";

function formatDateTime(date: Date): string {
  const pad = (n: number) => n.toString().padStart(2, "0");
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ` +
    `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  );
}

export class ZkBioClient {
  private readonly http: AxiosInstance;
  private readonly accessToken: string;

  constructor(config: ZkBioConfig) {
    const baseURL = `${config.serverUrl.replace(/\/$/, "")}:${config.serverPort}`;
    this.accessToken = config.accessToken;
    this.http = axios.create({
      baseURL,
      timeout: 30000,
      headers: { "Content-Type": "application/json" },
    });
  }

  private url(path: string, query: Record<string, string> = {}): string {
    const params = new URLSearchParams({
      access_token: this.accessToken,
      ...query,
    });
    return `/api/${path}?${params.toString()}`;
  }

  private assertSuccess<T>(response: ZkBioResponse<T>, context: string): T {
    if (response.code < 0) {
      throw new Error(`ZKBio ${context} failed (${response.code}): ${response.message}`);
    }
    return response.data;
  }

  async addPerson(params: {
    pin: string;
    name: string;
    deptCode?: string;
    accLevelIds: string[];
    accStartTime?: string;
    accEndTime?: string;
  }): Promise<void> {
    const { data } = await this.http.post<ZkBioResponse>(
      this.url("person/add"),
      {
        pin: params.pin,
        name: params.name,
        deptCode: params.deptCode ?? "1",
        accLevelIds: params.accLevelIds.join(","),
        accStartTime: params.accStartTime ?? formatDateTime(new Date()),
        accEndTime: params.accEndTime ?? "2099-12-31 23:59:59",
      }
    );
    this.assertSuccess(data, "person/add");
  }

  async getPersonQr(pin: string): Promise<string> {
    const { data } = await this.http.post<ZkBioResponse<string>>(
      this.url("v2/person/getQrCode", { pin })
    );
    return this.assertSuccess(data, "person/getQrCode") as string;
  }

  async addVisitorRegistration(params: {
    persPersonPin: string;
    certNum: string;
    visitEmpName: string;
    visitEmpPhone?: string;
    visitReason: string;
    visitorCount: string;
    startTime: string;
    endTime: string;
    visLevels: string;
  }): Promise<void> {
    const { data } = await this.http.post<ZkBioResponse>(
      this.url("visRegistration/add"),
      {
        persPersonPin: params.persPersonPin,
        certType: "8",
        certNum: params.certNum,
        visitEmpName: params.visitEmpName,
        visitEmpPhone: params.visitEmpPhone ?? "",
        company: "",
        visitReason: params.visitReason,
        visitorCount: params.visitorCount,
        startTime: params.startTime,
        endTime: params.endTime,
        cardNo: "",
        visLevels: params.visLevels,
      }
    );
    this.assertSuccess(data, "visRegistration/add");
  }

  async getVisitorQr(pin: string): Promise<string> {
    const { data } = await this.http.post<ZkBioResponse<string>>(
      this.url("visRegistration/getQrCode", { pin })
    );
    return this.assertSuccess(data, "visRegistration/getQrCode") as string;
  }

  async getVisitorQrByCert(certNumber: string, phone?: string): Promise<string> {
    const query: Record<string, string> = {
      certNumber,
      certType: "8",
    };
    if (phone) query.phone = phone;
    const { data } = await this.http.post<ZkBioResponse<string>>(
      this.url("v2/visRegistration/getQrCodeByCertNumber", query)
    );
    return this.assertSuccess(data, "getQrCodeByCertNumber") as string;
  }

  async checkoutVisitor(certNum: string): Promise<void> {
    const { data } = await this.http.post<ZkBioResponse>(
      this.url("visRegistration/exit", { certType: "8", certNum })
    );
    this.assertSuccess(data, "visRegistration/exit");
  }

  async syncPersonLevel(pin: string, levelIds: string[]): Promise<void> {
    const { data } = await this.http.post<ZkBioResponse>(
      this.url("accLevel/syncPerson", {
        pin,
        levelIds: levelIds.join(","),
      })
    );
    this.assertSuccess(data, "accLevel/syncPerson");
  }

  async personLeave(pin: string): Promise<void> {
    const { data } = await this.http.post<ZkBioResponse>(this.url("person/leave"), { pin });
    this.assertSuccess(data, "person/leave");
  }

  async listTransactions(params: {
    personPin?: string;
    pageNo?: number;
    pageSize?: number;
  }): Promise<unknown[]> {
    const query: Record<string, string> = {
      pageNo: String(params.pageNo ?? 1),
      pageSize: String(params.pageSize ?? 50),
    };
    if (params.personPin) query.personPin = params.personPin;
    const { data } = await this.http.get<ZkBioResponse<{ data?: unknown[] }>>(
      this.url("v2/transaction/list", query)
    );
    const result = this.assertSuccess(data, "transaction/list");
    if (Array.isArray(result)) return result;
    if (result && typeof result === "object" && "data" in result) {
      const nested = (result as { data?: unknown[] }).data;
      return Array.isArray(nested) ? nested : [];
    }
    return [];
  }
}

export { formatDateTime };
