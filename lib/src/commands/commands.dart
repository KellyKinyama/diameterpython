
import '../../diameter.dart';

/// A map of command codes to their corresponding message classes.
final Map<int, Type> allCommands = {
  // Base Protocol (RFC 6733)
  CapabilitiesExchange.CODE: CapabilitiesExchange,
  DeviceWatchdog.CODE: DeviceWatchdog,
  DisconnectPeer.CODE: DisconnectPeer,
  ReAuth.CODE: ReAuth,
  SessionTermination.CODE: SessionTermination,
  AbortSession.CODE: AbortSession,
  Accounting.CODE: Accounting,

  // Credit Control App (RFC 8506)
  CreditControl.CODE: CreditControl,

  // NASREQ App (RFC 7155)
  Aa.CODE: Aa,

  // EAP App (RFC 4072)
  DiameterEap.CODE: DiameterEap,

  // Mobile IP Apps (RFC 4004)
  AaMobileNode.CODE: AaMobileNode,
  HomeAgentMip.CODE: HomeAgentMip,

  // 3GPP Cx/Dx Interface (TS 29.229)
  UserAuthorization.CODE: UserAuthorization,
  ServerAssignment.CODE: ServerAssignment,
  LocationInfo.CODE: LocationInfo,
  MultimediaAuth.CODE: MultimediaAuth,
  RegistrationTermination.CODE: RegistrationTermination,
  PushProfile.CODE: PushProfile,

  // 3GPP Sy Interface (TS 29.219)
  SpendingLimit.CODE: SpendingLimit,
  SpendingStatusNotification.CODE: SpendingStatusNotification,
};
