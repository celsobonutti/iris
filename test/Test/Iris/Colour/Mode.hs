module Test.Iris.Colour.Mode (modeSpec) where

import Test.Hspec (Spec, it, describe, shouldReturn, before_)
import System.Environment (unsetEnv, setEnv)
import Data.Foldable (for_)
import System.IO (stdout, stderr)

import Iris.Cli.Colour (ColourOption (..))
import Iris.Colour.Mode (ColourMode (..), detectColourMode)

import Test.Iris.Common (checkCI)

modeSpec :: Spec
modeSpec = before_ clearAppEnv $ describe "Mode" $ do
    let detectStdoutColour option = detectColourMode stdout option (Just "myapp")
    let detectStderrColour option = detectColourMode stderr option (Just "myapp")

    it "DisableColour when --no-colour" $ do
        detectStdoutColour Never `shouldReturn` DisableColour
        detectStderrColour Never `shouldReturn` DisableColour

    it "EnableColour when --colour" $ do
        detectStdoutColour Always `shouldReturn` EnableColour
        detectStderrColour Always `shouldReturn` EnableColour

    it "EnableColour in clear environment" $ do
        detectStdoutColour Auto `shouldReturn` EnableColour
        detectStderrColour Auto `shouldReturn` EnableColour

    it "DisableColour when NO_COLOR is set" $ do
        setEnv "NO_COLOR" "1"
        detectStdoutColour Auto `shouldReturn` DisableColour
        detectStderrColour Auto `shouldReturn` DisableColour

    it "DisableColour when NO_COLOUR is set" $ do
        setEnv "NO_COLOUR" "1"
        detectStdoutColour Auto `shouldReturn` DisableColour
        detectStderrColour Auto `shouldReturn` DisableColour

    it "DisableColour when MYAPP_NO_COLOR is set" $ do
        setEnv "MYAPP_NO_COLOR" "1"
        detectStdoutColour Auto `shouldReturn` DisableColour
        detectStderrColour Auto `shouldReturn` DisableColour

    it "DisableColour when MYAPP_NO_COLOUR is set" $ do
        setEnv "MYAPP_NO_COLOUR" "1"
        detectStdoutColour Auto `shouldReturn` DisableColour
        detectStderrColour Auto `shouldReturn` DisableColour

    it "DisableColour when TERM=dumb" $ do
        setEnv "TERM" "dumb"
        detectStdoutColour Auto `shouldReturn` DisableColour
        detectStderrColour Auto `shouldReturn` DisableColour

    it "EnableColour when TERM=xterm-256color" $ do
        setEnv "TERM" "xterm-256color"
        detectStdoutColour Auto `shouldReturn` EnableColour
        detectStderrColour Auto `shouldReturn` EnableColour

    it "DisableColour when CI is set" $ do
        isCi <- checkCI
        let ciColour = if isCi then DisableColour else EnableColour

        detectStdoutColour Auto `shouldReturn` ciColour
        detectStderrColour Auto `shouldReturn` ciColour

-- Helper functions

testEnvVars :: [String]
testEnvVars =
    [ "NO_COLOR"
    , "NO_COLOUR"
    , "MYAPP_NO_COLOR"
    , "MYAPP_NO_COLOUR"
    , "TERM"
    ]

clearAppEnv :: IO ()
clearAppEnv = for_ testEnvVars unsetEnv