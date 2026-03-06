// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Portalixmx';

  @override
  String get residentLogin => 'Acceso de Residentes';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get forgetPassword => 'Olvida tu contraseña';

  @override
  String welcomeMessage(Object name) {
    return 'Bienvenido $name';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardDescription =>
      'Here’s an overview of residents, payments, and requests';

  @override
  String get totalResidents => 'Total Residents';

  @override
  String get acceptedRequests => 'Accepted requests';

  @override
  String get totalPayments => 'Payments';

  @override
  String get totalComplaints => 'Total Complaints';

  @override
  String get totalAccess => 'Total Access Requests';

  @override
  String get accessRequests => 'Solicitudes de Acceso';

  @override
  String residentsOfTheSociety(Object society) {
    return 'Residents of the $society';
  }

  @override
  String get poolAccess => 'Acceso a la Piscina';

  @override
  String get joinedOn => 'Joined On';

  @override
  String get residents => 'Residents';

  @override
  String get newRequests => 'New Requests';

  @override
  String get emptyResidentsMsg =>
      'The residents of the society will appear here';

  @override
  String get emptyResidentRequestsMsg =>
      'The new requests from the residents will appear here';

  @override
  String get approve => 'Approve';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get paymentFor => 'Payment for';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get receipt => 'Payment Receipt';

  @override
  String get add => 'Agregar';

  @override
  String get pending => 'Pending';

  @override
  String get received => 'Received';

  @override
  String get twoStepVerification => 'Verificación en 2 Pasos';

  @override
  String get twoStepVerificationDescription =>
      'Ingrese el código de verificación de 2 pasos enviado a su correo electrónico';

  @override
  String get otp => 'Código OTP';

  @override
  String get submit => 'Enviar';

  @override
  String get needHelp => '¿Necesitas ayuda?';

  @override
  String get home => 'Inicio';

  @override
  String get payments => 'Pagos';

  @override
  String get maintenance => 'Mantenimiento';

  @override
  String get access => 'Acceso';

  @override
  String get menu => 'Menú';

  @override
  String get guest => 'Invitado';

  @override
  String get requestedTime => 'HORA SOLICITADA';

  @override
  String get accessFor => 'Acceso Para';

  @override
  String get teacher => 'Profesor';

  @override
  String get accessApprovedDate => 'Fecha de Aprobación de Acceso';

  @override
  String get contactNum => 'Número de Contacto';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get from => 'De';

  @override
  String get to => 'A';

  @override
  String get shareKey => 'Compartir Clave';

  @override
  String get qrCode => 'CÓDIGO QR';

  @override
  String get paymentsAndBilling => 'Pagos y Facturación';

  @override
  String get currentService => 'Servicio Actual';

  @override
  String get otherServices => 'Otros Servicios';

  @override
  String get serviceName => 'Nombre del Servicio';

  @override
  String get cleaningOfCommonAreas => 'Limpieza de áreas comunes';

  @override
  String get garbageCollection => 'Recolección de basura';

  @override
  String get complaint => 'Queja';

  @override
  String get uploadPhotos => 'Subir Fotos';

  @override
  String get openCamera => 'Abrir Cámara';

  @override
  String get requestAccess => 'Solicitar Acceso';

  @override
  String get viewProfile => 'Ver Perfil';

  @override
  String get directory => 'Directorio';

  @override
  String get communityCalendar => 'Calendario Comunitario';

  @override
  String get communityPolls => 'Encuestas Comunitarias';

  @override
  String get guards => 'Guardias';

  @override
  String get carPooling => 'Compartir Auto';

  @override
  String get emergencyCalls => 'Llamadas de Emergencia';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get search => 'Buscar';

  @override
  String get guardTracking => 'Seguimiento de Guardias';

  @override
  String get name => 'Nombre';

  @override
  String get phone => 'Teléfono';

  @override
  String get emergencyContacts => 'Contactos de Emergencia';

  @override
  String get vehicleInformation => 'Información del Vehículo';

  @override
  String get vehicleName => 'Nombre del Vehículo';

  @override
  String get licensePlateNumber => 'Número de Placa';

  @override
  String get registrationNumber => 'Número de Registro';

  @override
  String get update => 'Actualizar';

  @override
  String get color => 'Color';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String updateYour(Object userInfo) {
    return 'Actualiza tu $userInfo';
  }

  @override
  String get addGuest => 'Agregar Invitado';

  @override
  String get deleteComplaint => 'Eliminar Queja';

  @override
  String get profileInfoUpdated => 'Información de perfil actualizada';

  @override
  String get profileInfoUpdateFailed =>
      'Error al actualizar el perfil, por favor intenta de nuevo';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get deleteVisitor => 'Eliminar Visitante';

  @override
  String get deleteGuest => 'Eliminar invitado';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get editGuest => 'Editar Invitado';

  @override
  String get carPlateNumber => 'Número de Placa del Auto';

  @override
  String get vehicleModel => 'Modelo del Vehículo';

  @override
  String get time => 'Hora';

  @override
  String get date => 'Fecha';

  @override
  String hasBeenEditedMessage(Object name) {
    return '$name ha sido actualizado';
  }

  @override
  String hasBeenAddedMessage(Object guestType, Object name) {
    return '$name ha sido agregado como $guestType';
  }

  @override
  String accessRequestPending(Object accessTitle) {
    return 'La solicitud de $accessTitle ya está en estado pendiente';
  }

  @override
  String accessRequestSubmitted(Object accessTitle) {
    return 'La solicitud de $accessTitle ha sido enviada al administrador de Portalix';
  }

  @override
  String get createAccount => 'Create Admin Account';

  @override
  String get createAccountDescription =>
      'Create Portalixmx resident admin account and get started with the society management';

  @override
  String get selectSociety => 'Select society';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get completeProfileDescription =>
      'Please provide the rest information to complete your profile';

  @override
  String get additionalDetails => 'Additional Details';

  @override
  String get pleaseEnterName => 'Por favor ingrese el nombre';

  @override
  String get pleaseEnterContactNumber =>
      'Por favor ingrese el número de contacto';

  @override
  String get pleaseEnterCarPlateNumber =>
      'Por favor ingrese el número de placa del auto';

  @override
  String get pleaseEnterVehicleModel =>
      'Por favor ingrese el modelo del vehículo';

  @override
  String get pleaseEnterColor => 'Por favor ingrese el color';

  @override
  String get pleaseSelectFromDateTime =>
      'Por favor seleccione la fecha y hora de inicio';

  @override
  String get pleaseSelectToDateTime =>
      'Por favor seleccione la fecha y hora de fin';

  @override
  String get toDateTimeMustBeAfterFromDateTime =>
      'La fecha/hora de fin debe ser posterior a la fecha/hora de inicio';

  @override
  String get pleaseSelectAtLeastOneDay =>
      'Por favor seleccione al menos un día con horario';

  @override
  String get visitorAddedSuccessfully => 'Visitante agregado exitosamente';

  @override
  String get visitorUpdatedSuccessfully => 'Visitante actualizado exitosamente';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get error => 'Error';

  @override
  String get all => 'All';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get automaticVisitorCode => 'Visitor Code';

  @override
  String get generateAccessCode => 'Generate Access Code';
}
