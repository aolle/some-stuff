import javax.xml.bind.DatatypeConverter;

/**
 * 
 * @author Àngel Ollé Blázquez
 * 
 * Clase para obtener la private key en formato PEM a partir de la clave pkcs8 extraída de los heap dumps.
 * 
 * 
 */

public class CreateRSAPrivateKey2 {
	
    private static final String BEGINRSA = "-----BEGIN RSA PRIVATE KEY-----\n";
    private static final String ENDRSA = "\n-----END RSA PRIVATE KEY-----\n";
    private static final int CHARS = 64;

	public static void main(String[] args) throws Exception {

		byte[] key = {0x0, 0x0}; // Clave en bytes. [-128, 127]. Realizar casting a valores negativos, P.E: {0x30, (byte)0x82, ... };
			
		char[] b64key = DatatypeConverter.printBase64Binary(key).toCharArray();
		String pemkey = BEGINRSA;
		
		for(int i = 0; i < b64key.length; i++) {
			if(i % CHARS == 0 && i != 0) {
				pemkey += "\n";
			}
			pemkey += b64key[i];
		}
		pemkey += ENDRSA;
				
		System.out.println(pemkey);
		
	}

}

