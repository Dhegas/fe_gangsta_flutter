enum UserRole {
  customer,
  partner,
  admin,
}

UserRole? parseUserRole(String? raw) {
  if (raw == null) {
    return null;
  }

  switch (raw.trim().toUpperCase()) {
    case 'CUSTOMER':
      return UserRole.customer;
    case 'PARTNER':
    case 'MERCHANT':
    case 'OWNER':
      return UserRole.partner;
    case 'ADMIN':
      return UserRole.admin;
    default:
      return null;
  }
}
