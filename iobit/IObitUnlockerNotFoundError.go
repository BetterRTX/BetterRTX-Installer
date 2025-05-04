package iobit

import (
	"fmt"
)

type IObitUnlockerNotFound struct {
    path string
}

func (e *IObitUnlockerNotFound) Error() string {
    return fmt.Sprintf("IObit Unlocker Not Found at path %s", e.path)
}
