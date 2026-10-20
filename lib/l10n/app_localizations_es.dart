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
  String get enterEmailToSendPasswordReset =>
      'Ingresa tu correo electrónico; se enviará un enlace para restablecer la contraseña';

  @override
  String get forgetPassLinkSent =>
      'Enlace de restablecimiento de contraseña enviado';

  @override
  String get checkYourEmailAddress =>
      'Por favor revisa tu correo electrónico; se envió un enlace para restablecer la contraseña.';

  @override
  String accountRequestPending(Object societyName) {
    return 'Tu solicitud de administrador para $societyName está pendiente. Serás notificado cuando el administrador actualice tu solicitud';
  }

  @override
  String get uploadYourProfileImage => 'Por favor sube tu imagen de perfil';

  @override
  String welcomeMessage(Object name) {
    return 'Bienvenido $name';
  }

  @override
  String get dashboard => 'Panel';

  @override
  String get dashboardDescription =>
      'Aquí tienes un resumen de residentes, pagos y solicitudes';

  @override
  String get totalResidents => 'Total de Residentes';

  @override
  String get acceptedRequests => 'Solicitudes aceptadas';

  @override
  String get totalPayments => 'Pagos';

  @override
  String get totalComplaints => 'Total de Quejas';

  @override
  String get totalAccess => 'Total de Solicitudes de Acceso';

  @override
  String get accessRequests => 'Solicitudes de Acceso';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get paymentDetail => 'Detalles del Pago';

  @override
  String residentsOfTheSociety(Object society) {
    return 'Residentes de $society';
  }

  @override
  String get poolAccess => 'Acceso a la Piscina';

  @override
  String get joinedOn => 'Se unió el';

  @override
  String get residents => 'Residentes';

  @override
  String get newRequests => 'Nuevas Solicitudes';

  @override
  String get emptyResidentsMsg =>
      'Los residentes de la sociedad aparecerán aquí';

  @override
  String get emptyResidentRequestsMsg =>
      'Las nuevas solicitudes de los residentes aparecerán aquí';

  @override
  String get approve => 'Aprobar';

  @override
  String get paymentDetails => 'Detalles del Pago';

  @override
  String get paymentFor => 'Pago por';

  @override
  String get status => 'Estado';

  @override
  String get description => 'Descripción';

  @override
  String get amount => 'Monto';

  @override
  String get receipt => 'Recibo de Pago';

  @override
  String get add => 'Agregar';

  @override
  String get pending => 'Pendiente';

  @override
  String get approved => 'Aprobado';

  @override
  String get received => 'Recibido';

  @override
  String get submitted => 'Enviado';

  @override
  String get markAsResolved => 'Marcar como resuelto';

  @override
  String get markAsInProgress => 'Marcar como En progreso';

  @override
  String get markAsReceived => 'Marcar como recibido';

  @override
  String get paymentHistory => 'Historial de Pagos';

  @override
  String get paymentToAdmin => 'Pago al Administrador';

  @override
  String get reject => 'Rechazar';

  @override
  String get aboutResident => 'Acerca del Residente';

  @override
  String get houseNumber => 'Número de Casa';

  @override
  String get aboutComplaint => 'Acerca de la Queja';

  @override
  String get createNewAccess => 'Crear nuevo acceso';

  @override
  String get title => 'Título';

  @override
  String get freeToUse => 'Uso libre';

  @override
  String get setItFreeToUse => 'Establecer, Uso libre';

  @override
  String get setItRequestToUse => 'Establecer, Solicitar uso';

  @override
  String get createEvent => 'Crear Evento';

  @override
  String get eventTitle => 'Título del Evento';

  @override
  String get eventDescription => 'Ingresa los detalles del evento';

  @override
  String get eventDateAndTime => 'Fecha y Hora';

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
  String get dateFrom => 'Fecha desde';

  @override
  String get dateTo => 'Fecha hasta';

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
  String get createPoll => 'Crear Encuesta';

  @override
  String get pollQuestion => 'Pregunta de la Encuesta';

  @override
  String get addOption => 'Agregar Opción';

  @override
  String get guards => 'Guardias';

  @override
  String get carPooling => 'Compartir Auto';

  @override
  String get emergencyCalls => 'Llamadas de Emergencia';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsCondition => 'Términos y Condiciones';

  @override
  String get address => 'Dirección';

  @override
  String get societyInformationUpdated =>
      'Información de la sociedad actualizada exitosamente';

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
  String get createAccount => 'Crear Cuenta';

  @override
  String get createAccountDescription =>
      'Crea una cuenta de administrador residente de Portalixmx y comienza con la gestión de la sociedad';

  @override
  String get selectSociety => 'Seleccionar sociedad';

  @override
  String get failedToLoadSocieties =>
      'No se pudieron cargar las sociedades. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get alreadyHaveAnAccount => '¿Ya tienes una cuenta? ';

  @override
  String get dontHaveAnAccount => '¿No tienes una cuenta? ';

  @override
  String get completeProfile => 'Completar Perfil';

  @override
  String get completeProfileDescription =>
      'Proporciona el resto de la información para completar tu perfil';

  @override
  String get additionalDetails => 'Detalles Adicionales';

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
  String get unableToLoadProfile =>
      'No se pudo cargar tu perfil. Inicia sesión de nuevo.';

  @override
  String get error => 'Error';

  @override
  String get all => 'Todos';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get year => 'Año';

  @override
  String get automaticVisitorCode => 'Código de Visitante';

  @override
  String get generateAccessCode => 'Generar Código de Acceso';

  @override
  String get communityMembers => 'Miembros de la Comunidad';

  @override
  String get editCommunity => 'Editar Comunidad';

  @override
  String get fundManagement => 'Gestión de Fondos';

  @override
  String get createFundReport => 'Crear Informe de Fondos';

  @override
  String get reportTitle => 'Título del Informe';

  @override
  String get income => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get expenseLabel => 'Concepto del Gasto';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get balance => 'Saldo';

  @override
  String get note => 'Nota';

  @override
  String get publishReport => 'Publicar Informe';

  @override
  String get saveAsDraft => 'Guardar como Borrador';

  @override
  String get published => 'Publicado';

  @override
  String get draft => 'Borrador';

  @override
  String get emptyFundReportsMsg => 'Aún no hay informes de fondos';

  @override
  String get totalExpenses => 'Gastos Totales';

  @override
  String get noExpenses => 'No hay gastos registrados';

  @override
  String get transferOwnership => 'Transferir Propiedad';

  @override
  String get transferOwnershipDescription =>
      'Entrega la gestión de la sociedad a otro administrador que ya se haya registrado para esta sociedad. Perderás el acceso de administrador.';

  @override
  String get selectNewAdmin => 'Seleccionar nuevo administrador';

  @override
  String get confirmTransfer => 'Confirmar Transferencia';

  @override
  String confirmTransferMessage(String name) {
    return '¿Transferir la propiedad a $name? Perderás el acceso de administrador inmediatamente.';
  }

  @override
  String get transferSuccess => 'Propiedad transferida exitosamente';

  @override
  String get noTransferCandidates =>
      'Ningún otro administrador se ha registrado para esta sociedad';

  @override
  String get notSocietyOwner =>
      'Solo el propietario de la sociedad puede transferir la propiedad';

  @override
  String get cancel => 'Cancelar';

  @override
  String get showReportToResidents => 'Mostrar informe a los residentes';

  @override
  String get emergencyCall => 'LLAMADA DE EMERGENCIA';

  @override
  String get emergencyContact => 'Contacto de Emergencia';

  @override
  String get removeContact => 'Eliminar Contacto';

  @override
  String get selectEmergencyContacts => 'Seleccionar Contactos de Emergencia';

  @override
  String get emergencyAlertSent => 'Alerta de emergencia enviada correctamente';

  @override
  String get noEmergencyContacts =>
      'No hay contactos de emergencia seleccionados';

  @override
  String get noReachableContacts => 'Ningún contacto es alcanzable';

  @override
  String get holdToSendAlert =>
      'Mantén presionado 3 segundos para enviar una alerta';

  @override
  String get emptyEmergencyContactsMsg =>
      'Tus contactos de emergencia aparecerán aquí';

  @override
  String get save => 'Guardar';

  @override
  String eventCreated(Object name) {
    return '¡El evento \'$name\' ha sido creado!';
  }

  @override
  String get failedToCreateEvent =>
      '¡Error al crear el evento!, Inténtalo de nuevo';

  @override
  String eventDeleted(Object name) {
    return '¡El evento \'$name\' ha sido eliminado!';
  }

  @override
  String get failedToDeleteEvent => 'Error al eliminar el evento';

  @override
  String get pollCreated => '¡Encuesta comunitaria creada!';

  @override
  String get pollDeleted => '¡La encuesta ha sido eliminada!';

  @override
  String get failedToDeletePoll => 'Error al eliminar la encuesta';

  @override
  String get paymentCreated =>
      'Nuevo pago creado y enviado a todos los residentes';

  @override
  String paymentDeleted(Object name) {
    return '¡El pago \'$name\' ha sido eliminado!';
  }

  @override
  String get failedToCreatePayment => 'Error al crear el pago';

  @override
  String get failedToDeletePayment => 'Error al eliminar el pago';

  @override
  String accessCreated(Object name) {
    return '¡El acceso \'$name\' ha sido creado!';
  }

  @override
  String get failedToCreateAccess => 'Error al crear el acceso';

  @override
  String fundReportCreated(Object name) {
    return '¡El informe de fondos \'$name\' ha sido creado!';
  }

  @override
  String get failedToCreateFundReport => 'Error al crear el informe de fondos';

  @override
  String get paymentToAdminSubmitted =>
      'Pago enviado al administrador exitosamente';

  @override
  String get failedToSubmitPaymentToAdmin =>
      'Error al enviar el pago al administrador';

  @override
  String get failedToCreatePoll => 'Error al crear la encuesta';

  @override
  String get regularVisitors => 'Visitantes Frecuentes';

  @override
  String get regularVisitor => 'Visitante Frecuente';
}
