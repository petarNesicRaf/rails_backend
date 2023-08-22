class AuthenticationTokenService
    HMAC_SECRET = 'my$ecretK3y'
    ALGORITHM_TYPE = 'HS256'
    
    def self.call(username, role)
        payload = {username: username, role: role}

        token = JWT.encode payload, HMAC_SECRET, ALGORITHM_TYPE
    end

    def self.decode(token)
        decoded_token = JWT.decode token, HMAC_SECRET, true, {algorithm: ALGORITHM_TYPE}
        {'username' => decoded_token[0]['username'], 'role'=>decoded_token[0]['role']}
    end
end