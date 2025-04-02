@RestController
public class BackendAController {

    @GetMapping("/data")
    public String getData() {
        return "Antwort von Backend A";
    }
}
