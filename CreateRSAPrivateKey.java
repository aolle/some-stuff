import java.lang.reflect.Field;
import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.spec.RSAPrivateCrtKeySpec;
import javax.xml.bind.DatatypeConverter;

/**
 * 
 * @author Àngel Ollé Blázquez
 * 
 * Clase para obtener la private key en formato PEM a partir de los miembros RSA.
 * 
 * Uso de java reflection para "hookear" el atributo mag de los BigInteger extraídos de los heap dumps.
 *
 */
public class CreateRSAPrivateKey {
	
    private BigInteger n;       // modulus
    private BigInteger e;       // public exponent
    private BigInteger d;       // private exponent
    private BigInteger p;       // prime p
    private BigInteger q;       // prime q
    private BigInteger pe;      // prime exponent p
    private BigInteger qe;      // prime exponent q
    private BigInteger coeff;   // CRT coeffcient
    
    private static final String BEGINRSA = "-----BEGIN RSA PRIVATE KEY-----\n";
    private static final String ENDRSA = "\n-----END RSA PRIVATE KEY-----\n";
    private static final int CHARS = 64;
	
	public static void main(String args[]) throws Exception {
		// Inicializamos con un valor positivo, por definicion de numero primo. Tambien lo vemos en el campo signum del BigInteger del heapdump
		BigInteger bi = BigInteger.valueOf(1);
		// valores RSA 
		int[] n = {0, 0, 0}; // mag del BigDecimal. Ejemplo: {1041061428, -871723582, -1827852598, ... };
		int[] e = {0, 0, 0};
		int[] d = {0, 0, 0};
		int[] p = {0, 0, 0};
		int[] q = {0, 0, 0};
		int[] pe = {0, 0, 0};
		int[] qe = {0, 0, 0};
		int[] coeff = {0, 0, 0};
		
		// asignamos los valores en los atributos de la clase usando como modelo el BigInteger modificado por reflexion.
		CreateRSAPrivateKey rsa = new CreateRSAPrivateKey();
		rsa.n = changeAndReturnNewValue(bi, n);
		rsa.e = changeAndReturnNewValue(bi, e);
		rsa.d = changeAndReturnNewValue(bi, d);
		rsa.p = changeAndReturnNewValue(bi, p);
		rsa.q = changeAndReturnNewValue(bi, q);
		rsa.pe = changeAndReturnNewValue(bi, pe);
		rsa.qe = changeAndReturnNewValue(bi, qe);
		rsa.coeff = changeAndReturnNewValue(bi, coeff);

		// Creamos clave privada a partir de su especificacion RSA
		RSAPrivateCrtKeySpec spec = new RSAPrivateCrtKeySpec(rsa.n, rsa.e, rsa.d, rsa.p, rsa.q, rsa.pe, rsa.qe, rsa.coeff);
		PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(spec);
		String pemkey = BEGINRSA;
		char[] b64key = DatatypeConverter.printBase64Binary(privateKey.getEncoded()).toCharArray();
		
		for(int i = 0; i < b64key.length; i++) {
			if(i % CHARS == 0 && i != 0) {
				pemkey += "\n";
			}
			pemkey += b64key[i];
		}
		pemkey += ENDRSA;
		
		//Imprimimos la clave privada
		System.out.println(pemkey);
		
	}
	
	// reflection
	static BigInteger changeAndReturnNewValue(BigInteger bi, int[] mag) throws Exception {
		Field magField = bi.getClass().getDeclaredField("mag");
		magField.setAccessible(true);
		magField.set(bi, mag);
		return new BigInteger(bi.toByteArray());
	}

}
