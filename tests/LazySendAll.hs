-- | Steps to reproduce this problem:
--
-- 1. Run a simple TCP server, e.g. using: netcat -l 127.0.0.1 -p 42940
-- 2. Run this executable
-- 3. The message "SBL.sendAll finished" is never printed
--
module Main where

import qualified Data.ByteString.Lazy.Char8     as BL8
import qualified Network.Socket                 as S
import qualified Network.Socket.ByteString.Lazy as SBL

main :: IO ()
main = do
    let hints = S.defaultHints {S.addrSocketType = S.Stream}
        host  = "127.0.0.1"
        port  = 42940 :: Int

    addr : _ <- S.getAddrInfo (Just hints) (Just host) (Just $ show port)
    sock     <- S.socket (S.addrFamily addr) S.Stream S.defaultProtocol
    S.setSocketOption sock S.NoDelay 1

    let message :: BL8.ByteString
        message = BL8.pack "HTTP/1.1 101 WebSocket Protocol Handshake\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: qQ9gwyLSBO/9sGfzx5dBwnbfOGM=\r\n\r\n"

    S.connect sock (S.addrAddress addr)
    SBL.sendAll sock message
    putStrLn "SBL.sendAll finished"
    S.close sock
