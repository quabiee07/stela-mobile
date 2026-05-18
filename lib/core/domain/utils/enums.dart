enum UserRole { user, seller}


//function that converts enum to String
 String toTypeString(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'user';
      case UserRole.seller:
        return 'seller';
      }
  }

   UserRole fromString(String userRole) {
    switch (userRole) {
      case 'user':
        return UserRole.user;
      case 'seller':
        return UserRole.seller;
      default:
        throw Exception('Unknown user type');
    }
  }