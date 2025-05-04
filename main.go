package main 


import (
	// "fmt"
	"log"
	// "os/exec"
	// "os"
	// "installer/iobit"
)

func main() {
	log.Println("Test")

	// iobit.Test("go")
	// log.Print(iobit.Copy("C:\\Users\\buckn\\Desktop\\GitHub\\BetterRTX\\installer\\README.md", "C:\\Users\\buckn\\Documents\\Minecraft"))
	// log.Print(iobit.Delete("C:\\Users\\buckn\\Documents\\Minecraft\\README.md"))


}
// func main() {
// 	// Create a new Cmd struct
// 	cmd := exec.Command("ls", "-l")

// 	// Run the command and wait for it to complete
// 	err := cmd.Run()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	// Print the output of the command
// 	output, err := cmd.Output()
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	fmt.Println(string(output))

// 	// Start the command in the background
// 	cmd = exec.Command("sleep", "5")
// 	err = cmd.Start()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	// Wait for the command to complete
// 	err = cmd.Wait()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	fmt.Println("Sleep command completed")
// }